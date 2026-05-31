import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Presentation/Viewmodels/user_viewmodel.dart';
import 'package:workout_planner/Features/Presentation/Widgets/weight_chart.dart';

class UserScreen extends ConsumerStatefulWidget {
  const UserScreen({super.key});

  @override
  ConsumerState<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends ConsumerState<UserScreen> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  List<double> _history = [];
  List<String> _historyDates = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final vm = ref.read(userViewModelProvider);
    await vm.loadUser();
    if (vm.user != null) {
      _nameController.text = vm.user!.name;
      _heightController.text = vm.user!.height.toString();
      _weightController.text = vm.user!.weight.toString();
    }
    await _loadHistory();
    setState(() {});
  }

  Future<void> _loadHistory() async {
    final ds = ref.read(localUserDataSourceProvider);
    final rows = await ds.getWeightHistory();
    setState(() {
      _history = rows
          .map((r) => ((r['weight'] ?? 0) as num).toDouble())
          .toList();
      _historyDates = rows.map((r) => (r['date'] ?? '').toString()).toList();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(userViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('User')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: vm.nameError,
                ),
                onChanged: vm.updateName,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _heightController,
                      decoration: InputDecoration(
                        labelText: 'Height (m)',
                        errorText: vm.heightError,
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (v) {
                        final parsed = double.tryParse(v) ?? 0.0;
                        vm.updateHeight(parsed);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _weightController,
                      decoration: InputDecoration(
                        labelText: 'Weight (kg)',
                        errorText: vm.weightError,
                      ),
                      keyboardType: TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      onChanged: (v) {
                        final parsed = double.tryParse(v) ?? 0.0;
                        vm.updateWeight(parsed);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Sex:'),
                  const SizedBox(width: 12),
                  DropdownButton<int>(
                    value: vm.user?.sex ?? 0,
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Unspecified')),
                      DropdownMenuItem(value: 1, child: Text('Male')),
                      DropdownMenuItem(value: -1, child: Text('Female')),
                    ],
                    onChanged: (v) {
                      if (v != null) vm.updateSex(v);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'BMI: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(vm.bmiValue.toStringAsFixed(2)),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(vm.bmiCategory),
                    backgroundColor: vm.bmiCategory == 'normal'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Weight history'),
              const SizedBox(height: 8),
              WeightChart(weights: _history, dates: _historyDates),
              const SizedBox(height: 24),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final success = await vm.save();
                      if (success && mounted) {
                        await _loadHistory();
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Saved')));
                      } else if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Validation failed')),
                        );
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

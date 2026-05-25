import 'package:flutter/material.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/set_data.dart';
import 'package:workout_planner/Features/Domain/Entities/Performance/performance_type.dart';

class SetRowWidget extends StatefulWidget {
  final int setNumber;
  final SetData set;
  final PerformanceType type;
  final VoidCallback onDelete;
  final Function(SetData) onUpdate;

  const SetRowWidget({
    super.key,
    required this.setNumber,
    required this.set,
    required this.type,
    required this.onDelete,
    required this.onUpdate,
  });

  @override
  State<SetRowWidget> createState() => _SetRowWidgetState();
}

class _SetRowWidgetState extends State<SetRowWidget> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;
  late TextEditingController _durationController;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(
      text: widget.set.weight?.toString() ?? '',
    );
    _repsController = TextEditingController(
      text: widget.set.reps?.toString() ?? '',
    );
    _durationController = TextEditingController(
      text: widget.set.duration?.toString() ?? '',
    );
  }

  @override
  void didUpdateWidget(SetRowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.set != widget.set) {
      _weightController.text = widget.set.weight?.toString() ?? '';
      _repsController.text = widget.set.reps?.toString() ?? '';
      _durationController.text = widget.set.duration?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  void _updateSet() {
    SetData newSet;
    switch (widget.type) {
      case PerformanceType.weighted:
        final weight = double.tryParse(_weightController.text) ?? 0;
        final reps = int.tryParse(_repsController.text) ?? 0;
        newSet = SetData.weighted(weight: weight, reps: reps);
        break;
      case PerformanceType.bodyweight:
        final reps = int.tryParse(_repsController.text) ?? 0;
        newSet = SetData.bodyweight(reps: reps);
        break;
      case PerformanceType.duration:
        final duration = double.tryParse(_durationController.text) ?? 0;
        newSet = SetData.duration(duration: duration);
        break;
    }
    widget.onUpdate(newSet);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              '${widget.setNumber + 1}',
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildInputFields(),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: widget.onDelete,
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    switch (widget.type) {
      case PerformanceType.weighted:
        return Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _weightController,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateSet(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextFormField(
                controller: _repsController,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _updateSet(),
              ),
            ),
          ],
        );
      case PerformanceType.bodyweight:
        return TextFormField(
          controller: _repsController,
          decoration: const InputDecoration(
            labelText: 'Reps',
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _updateSet(),
        );
      case PerformanceType.duration:
        return TextFormField(
          controller: _durationController,
          decoration: const InputDecoration(
            labelText: 'Duration (min)',
            isDense: true,
          ),
          keyboardType: TextInputType.number,
          onChanged: (_) => _updateSet(),
        );
    }
  }
}
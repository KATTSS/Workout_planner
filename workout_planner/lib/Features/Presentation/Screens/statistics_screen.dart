import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Presentation/Viewmodels/statistics_viewmodel.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(statisticsViewModelProvider);
    final statsAsync = viewModel.statistics;

    return Scaffold(
      appBar: AppBar(title: const Text('Statistics')),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatCard(
                'Total Workouts',
                '${stats.totalWorkouts}',
                Icons.fitness_center,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildStatCard(
                'Average Exercises',
                viewModel.getAverageExercisesString(
                  stats.averageExercisesPerWorkout,
                ),
                Icons.format_list_numbered,
                Colors.green,
              ),
              const SizedBox(height: 24),
              const Text(
                'Most Used Muscle Groups',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildHorizontalChart(
                viewModel.getTopMuscleGroups(stats.mostUsedMuscleGroups),
                viewModel.calculatePercentage,
              ),
              const SizedBox(height: 24),
              const Text(
                'Most Frequent Exercises',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildExerciseList(
                viewModel.getTopExercises(stats.mostFrequentExercises),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey.shade600)),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalChart(
    List<MapEntry<String, int>> topEntries,
    double Function(int value, int maxValue) calculatePercentage,
  ) {
    if (topEntries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No data available')),
        ),
      );
    }

    final maxValue = topEntries.first.value;

    return Column(
      children: topEntries.map((entry) {
        final percentage = calculatePercentage(entry.value, maxValue) * 100;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${entry.value} times',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: calculatePercentage(entry.value, maxValue),
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
                minHeight: 8,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildExerciseList(List<MapEntry<String, int>> topEntries) {
    if (topEntries.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No data available')),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: topEntries.length,
        separatorBuilder: (_, _) => const Divider(),
        itemBuilder: (context, index) {
          final entry = topEntries[index];
          return ListTile(
            leading: CircleAvatar(child: Text('${index + 1}')),
            title: Text(entry.key),
            trailing: Text(
              '${entry.value} times',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
          );
        },
      ),
    );
  }
}

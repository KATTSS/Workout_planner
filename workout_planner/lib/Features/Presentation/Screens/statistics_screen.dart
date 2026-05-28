// lib/Features/Presentation/screens/statistics_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Application/Providers/workout_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statisticsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total workouts
              _buildStatCard(
                'Total Workouts',
                '${stats.totalWorkouts}',
                Icons.fitness_center,
                Colors.blue,
              ),
              const SizedBox(height: 16),
              // Average exercises per workout
              _buildStatCard(
                'Average Exercises',
                stats.averageExercisesPerWorkout.toStringAsFixed(1),
                Icons.format_list_numbered,
                Colors.green,
              ),
              const SizedBox(height: 24),
              // Most used muscle groups
              const Text(
                'Most Used Muscle Groups',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildHorizontalChart(stats.mostUsedMuscleGroups),
              const SizedBox(height: 24),
              // Most frequent exercises
              const Text(
                'Most Frequent Exercises',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildExerciseList(stats.mostFrequentExercises),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
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
                Text(
                  title,
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHorizontalChart(Map<String, int> data) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No data available')),
        ),
      );
    }

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final maxValue = sortedEntries.first.value;

    return Column(
      children: sortedEntries.take(5).map((entry) {
        final percentage = (entry.value / maxValue) * 100;
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                  Text('${entry.value} times', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: percentage / 100,
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

  Widget _buildExerciseList(Map<String, int> data) {
    if (data.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No data available')),
        ),
      );
    }

    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedEntries.take(10).length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, index) {
          final entry = sortedEntries[index];
          return ListTile(
            leading: CircleAvatar(
              child: Text('${index + 1}'),
            ),
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
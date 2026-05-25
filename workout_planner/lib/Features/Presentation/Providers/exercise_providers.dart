import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_planner/Features/Data/Providers/data_providers.dart';
import 'package:workout_planner/Features/Domain/Entities/excercise.dart';

final exerciseSearchProvider = FutureProvider.family<List<Exercise>, String>(
  (ref, query) async {
    final exerciseRepo = ref.watch(exerciseRepoProvider);
    if (query.isEmpty) {
      return exerciseRepo.getAll();
    }
    return exerciseRepo.getByName(query);
  },
);

final exercisesByCategoryProvider = FutureProvider.family<List<Exercise>, String>(
  (ref, category) async {
    final exerciseRepo = ref.watch(exerciseRepoProvider);
    return exerciseRepo.getByCategory(category);
  },
);
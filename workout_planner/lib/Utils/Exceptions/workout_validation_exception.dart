class WorkoutValidationException implements Exception {
  final String message;
  WorkoutValidationException(this.message);

  @override
  String toString() {
    return '${runtimeType} : $message';
  }
}

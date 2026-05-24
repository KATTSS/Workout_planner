# Workout Planner

A mobile workout planning and tracking application built with **Flutter**, designed with a strong emphasis on **Clean Architecture**, **Domain-Driven Design (DDD)**, and **immutability**. It supports multiple exercise performance types (weighted, bodyweight, duration) and provides a full history of user workouts.


## Key Features

- **Multi-Type Exercises**: Supports `Weighted` (barbell, dumbbell), `Bodyweight`, and `Duration` (cardio, stretching) exercises.
- **Workout History**: Full CRUD operations on past workouts with the ability to query by date range.
- **Undo/Redo**: Built-in state management for editing workouts via the Memento pattern.
- **Immutable Domain Model**: All core entities (`Workout`, `ExercisePerformance`, `SetData`) are immutable, ensuring predictable state and no side effects.
- **SQL Query Builder**: Custom, fluent `QueryBuilder` that prevents SQL injection and builds queries programmatically.

## Architecture & Design Patterns

This project is a showcase of software design principles and patterns:

### Architectural Patterns
- **Clean Architecture**: Clear separation between `Domain`, `Data`, and `Application` layers.
- **Domain-Driven Design (DDD)**: The code uses the ubiquitous language of the domain (Workout, Exercise, Sets, Reps). `Workout` and `SetData` are treated as immutable Value Objects.

### Creational Patterns
- **Singleton**: `UserHistDb` and `ExerciseDb` ensure a single database connection instance.
- **Builder**: `WorkoutBuilder` and `QueryBuilder` use a fluent interface for step-by-step object construction.
- **Factory Method**: `ExercisePerformance.create()` is a factory that returns the correct subclass (`WeightedExercisePerformance`, etc.) based on the `PerformanceType`.

### Structural Patterns
- **Adapter**: Repository implementations (`HistoryRepo`, `ExerciseRepo`) adapt database services to the domain-layer interfaces (`IHistoryRepo`, `IExerciseRepo`).
- **Data Mapper**: `WorkoutMapper` and `ExerciseMapper` handle transformations between database models and domain entities.
- **Facade**: `WorkoutSession` provides a single, simplified interface for all workout editing and state management operations.

### Behavioral Patterns
- **Visitor**: `ExercisePerformanceVisitor<T>` enables performing operations across different exercise performance types without modifying their classes.
- **Command / Use Case**: Each business operation (`CreateWorkout`, `ManageWorkoutExercises.addExercise`) is encapsulated in its own class with a single responsibility.
- **Memento**: `WorkoutSessionManager` internally saves workout states to enable undo and redo functionality.

## Immutability

All domain entities are designed to be immutable. Methods like `addSet()`, `updateSet()`, or `copyWith()` do not mutate the original object but return a brand new instance. This makes state changes predictable, simplifies debugging, and integrates seamlessly with reactive UI frameworks like Flutter.

## Getting Started

### Prerequisites
- Flutter SDK
- Dart

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/KATTSS/Workout_planner
2. Navigate to the project directory:
   ```bash
   cd workout_planner
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Ensure your database assets are correctly placed in the `assets/databases/` folder and declared in `pubspec.yaml`.
5. Run the app:
   ```bash
   flutter run
   ```

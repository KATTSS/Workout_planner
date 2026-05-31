# Использованные паттерны в проекте WorkoutPlanner

## 1. Clean Architecture / Слоистая архитектура

Проект разделён на четыре слоя:
- Presentation — пользовательский интерфейс и ViewModel.
- Application — провайдеры состояния и DI через Riverpod.
- Domain — бизнес-логика, сущности, интерфейсы репозиториев и use cases.
- Data — реализация репозиториев, источники данных, модели и мапперы.

## 2. Repository Pattern

Интерфейсы:
- `IExerciseRepo`
- `IHistoryRepo`

Реализации:
- `ExerciseRepo`
- `HistoryRepo`

Преимущества:
- абстракция доступа к данным,
- возможность замены хранения (sqlite, сеть, мок).

## 3. Provider / Dependency Injection (Riverpod)

- `Provider` / `StateNotifierProvider` / `FutureProvider` / `ChangeNotifierProvider.family`
- Используется для инъекции `ExerciseRepo`, `HistoryRepo`, use cases и состояний.

## 4. StateNotifier Pattern

- `WorkoutSessionNotifier`
- `WorkoutBuilderNotifier`
- `ExerciseFiltersNotifier`

Обеспечивает управление состоянием, отделённое от UI.

## 5. Builder Pattern

- `WorkoutBuilder`

Позволяет поэтапно собирать объект `Workout`, затем валидировать и конструировать его.

## 6. Singleton Pattern

- `ExerciseDb`
- `UserHistDb`

Используется для одного экземпляра доступа к базе данных.

## 7. Factory Method

- `ExercisePerformance.create()`
- `SetData.weighted()`, `SetData.bodyweight()`, `SetData.duration()`
- `Equipment.fromString()`

Реализуют создание правильного класса/объекта в зависимости от данных.

## 8. Data Mapper Pattern

- `ExerciseMapper`
- `WorkoutMapper`

Отделяет доменные сущности от моделей базы данных.

## 9. Visitor Pattern

- `ExercisePerformanceVisitor<T>`

Позволяет реализовать операции над иерархией `ExercisePerformance`. 

## 10. Command / Undo-Redo Pattern

- `WorkoutSessionManager`

Хранит историю изменений состояния тренировки для поддержки undo/redo.

## 11. DTO / Model Pattern

- `ExerciseModel`
- `UserHistModel`

Модели служат переносом данных между базой и доменом.

## 12. Router / Navigation Pattern

- `AppRouter`

Инкапсулирует навигацию по именованным маршрутам и передачу аргументов между экранами.

## 13. Validation Exception

- `WorkoutValidationException`

Выделение ошибок валидации в отдельный тип позволяет централизованно обрабатывать бизнес-ошибки.

# Описание классов проекта WorkoutPlanner

## lib/main.dart

- `MyApp` — корневой `StatelessWidget`, настраивает `MaterialApp`, тему и стартовый экран (`HomeScreen`).
- `databaseInitProvider` — `FutureProvider`, который инициализирует базы данных `UserHistDb` и `ExerciseDb` при запуске.

## Features/Presentation/Screens

- `HomeScreen` — экран списка тренировок и доступа к созданию/копированию/удалению тренировок.
- `ExerciseCatalogScreen` — экран каталога упражнений с фильтрацией, поиском и выбором упражнений.
- `WorkoutDetailScreen` — экран детальной тренировки, где пользователь может редактировать упражнения, сеты, заметки и статус.
- `ExerciseDetailScreen` — экран детали упражнения для просмотра и редактирования отдельных сетов.
- `StatisticsScreen` — экран статистики тренировок, отображающий графики и сводные данные по выполненным тренировкам.

## Features/Presentation/Widgets

- `WorkoutCard` — визуальная карточка тренировки для списка, отображает дату, статус, количество упражнений и мышечную группу.
- `ExercisePerformanceWidget` — виджет для отображения одного упражнения и его производительности/сетовых данных.

## Features/Presentation/Viewmodels

- `HomeViewModel` — управляет загрузкой списка тренировок, удалением тренировок и созданием новых тренировок через `WorkoutBuilder` и `CreateWorkout`.
- `ExerciseCatalogViewModel` — управляет списком упражнений, фильтрами, поиском, а также созданием `ExercisePerformance` на основе выбранных упражнений.
- `ExerciseDetailViewModel` — `ChangeNotifier`, содержит состояние редактируемых сетов упражнения и трансформирует данные для UI.
- `WorkoutDetailViewModel` — управляет текущей тренировочной сессией, сохраняет и удаляет тренировку, добавляет/удаляет упражнения и сеты, выполняет undo/redo.
- `StatisticsViewModel` — предоставляет статистику тренировок и форматирует данные для отображения.

## Features/Application/Providers

- `exerciseDbProvider` — провайдер для доступа к экземпляру `ExerciseDb`.
- `userHistDbProvider` — провайдер для доступа к `UserHistDb`.
- `localWorkoutDataSourceProvider` — провайдер `ILocalWorkoutDataSource`, оборачивающий `UserHistDb`.
- `exerciseRepoProvider` — провайдер реализации `IExerciseRepo`.
- `historyRepoProvider` — провайдер реализации `IHistoryRepo`.
- `createWorkoutProvider`, `saveWorkoutProvider`, `deleteWorkoutProvider`, `getWorkoutHistoryProvider` — use case провайдеры для управления историей тренировок.
- `statisticsManagerProvider` — провайдер менеджера статистики.
- `exerciseCatalogProvider` — `FutureProvider`, возвращает полный каталог упражнений.
- `exerciseSearchProvider` — поиск упражнений по имени.
- `workoutSessionProvider` — `StateNotifierProvider`, управляет состоянием текущей тренировочной сессии.
- `workoutBuilderProvider` — `StateNotifierProvider`, управляет созданием новой тренировки.
- `exerciseFiltersProvider` — `StateNotifierProvider`, хранит фильтры каталога упражнений.
- `workoutHistoryChangeProvider` — `StateProvider<int>` для обновления статистики при изменении истории.
- `statisticsProvider` — `FutureProvider`, вычисляет статистику на основе истории тренировок.
- `workoutByIdProvider` — `FutureProvider.family`, возвращает тренировку по идентификатору.

## Features/Application/Providers/workout_states.dart

- `WorkoutSessionState` — состояние сессии, содержит `WorkoutSession`, флаг загрузки, ошибку и флаг несохранённых изменений.
- `WorkoutSessionNotifier` — контроллер сессии, делегирующий операции `WorkoutSession` и поддерживающий ошибки/статус.
- `WorkoutBuilderState` — состояние билдера тренировок, содержит `WorkoutBuilder`, готовую тренировку и флаг валидности.
- `WorkoutBuilderNotifier` — контроллер билдера для создания тренировок с валидацией.
- `ExerciseFiltersState` — состояние фильтров каталога упражнений.
- `ExerciseFiltersNotifier` — контроллер фильтров.
- `WorkoutStatistics` — агрегирует отчётные данные по completed-тренировкам.

## Features/Domain/Entities

- `Exercise` — доменная сущность упражнения: id, имя, уровень, категория, оборудование, описание, основная/второстепенная мышца, вычисляет `performanceType`.
- `ExerciseCategory` — enum категорий упражнений и логика `requiresWeight` / `isTimed`.
- `Equipment` — enum оборудования с фабричным методом `fromString`.
- `Workout` — доменная сущность тренировки: id, дата, список упражнений, статус завершения и заметки; рассчитывает основную мышцу, количество сетов, упражнения и задействованные группы.
- `SetData` — значение одного сета с `weight`, `reps` и `duration`, проверяет корректность в зависимости от типа упражнения.
- `PerformanceType` — enum типов производительности: `weighted`, `bodyweight`, `duration`.
- `ExercisePerformance` — абстрактная сущность исполнения упражнения с набором сетов и фабрикой `create()`.
- `WeightedExercisePerformance`, `BodyweightExercisePerformance`, `DurationExercisePerformance` — конкретные реализации `ExercisePerformance`.
- `ExercisePerformanceVisitor<T>` — интерфейс посетителя для операций над типами `ExercisePerformance`.
- `User` — сущность пользователя (файл `user.dart`).

## Features/Domain/Repository

- `IExerciseRepo` — интерфейс репозитория упражнений.
- `IHistoryRepo` — интерфейс репозитория истории тренировок.

## Features/Domain/UseCases

- `CreateWorkout` — use case создания новой тренировки через `IHistoryRepo`.
- `SaveWorkout` — use case сохранения/обновления тренировки.
- `DeleteWorkout` — use case удаления тренировки.
- `GetWorkoutHistory` — use case получения списка тренировок и поиска по датам.
- `StatisticsManager` — use case расчёта статистики на основе истории.
- `WorkoutBuilder` — билдeр для построения экземпляра `Workout`.
- `WorkoutSession` — сессия редактирования тренировки, инкапсулирующая менеджеры.
- `WorkoutSessionManager` — история изменений `Workout` для undo/redo.
- `WorkoutStatusManager` — управление датой, заметками и статусом тренировки.
- `ManageWorkoutExercises` — управление списком упражнений в тренировке.
- `SetManagement` — управление сетами упражнения.

## Features/Data/Service

- `ExerciseDb` — singleton для чтения предзаполненной базы упражнений из assets, предоставляет SQL-запросы через `QueryBuilder`.
- `UserHistDb` — singleton для хранения истории тренировок, инициализирует БД на основе `assets/db_init.sql`.
- `ILocalWorkoutDataSource` — интерфейс локального источника данных для истории тренировок.
- `LocalWorkoutDataSource` — реализация `ILocalWorkoutDataSource` поверх `UserHistDb`.
- `QueryBuilder` — строитель SQL-запросов.

## Features/Data/Repository

- `ExerciseRepo` — реализация `IExerciseRepo`, выполняет SQL-запросы к `ExerciseDb`, преобразует `ExerciseModel` в `Exercise` через `ExerciseMapper`.
- `HistoryRepo` — реализация `IHistoryRepo`, сохраняет/обновляет/удаляет тренировки и связанные сеты через `ILocalWorkoutDataSource`, собирает доменные объекты через `WorkoutMapper`.

## Features/Data/Models

- `ExerciseModel` — модель данных для таблицы упражнений.
- `UserHistModel` — модель данных для таблицы историй тренировок.

## Features/Data/Repository/Mappers

- `ExerciseMapper` — преобразует `ExerciseModel` в доменную сущность `Exercise`.
- `WorkoutMapper` — преобразует `Workout` в `UserHistModel`, формирует данные для таблиц упражнений/сетов, собирает `Workout` из моделей.

## Utils

- `AppRouter` — маршрутизатор приложения с именованными маршрутами для основных экранов.
- `WorkoutValidationException` — специфичное исключение для валидации тренировок.

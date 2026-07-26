import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/features/categories/business/models/category_model.dart';
import 'package:tudu/features/categories/application/categories_provider.dart';
import 'package:tudu/features/tasks/business/models/task_model.dart';
import 'package:tudu/features/tasks/application/tasks_provider.dart';
import 'package:tudu/features/notes/business/models/note_model.dart';
import 'package:tudu/features/notes/application/notes_provider.dart';
import 'package:tudu/features/settings/application/settings_provider.dart';
import 'package:tudu/shared/utils/date_utils.dart';

void main() {
  // Set up mock SharedPreferences before any tests run
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Model Serialization Tests', () {
    test('Category serialization and deserialization', () {
      final category = Category(
        id: 'cat-1',
        name: 'Work',
        colorValue: 0xFF4CAF50,
      );

      final json = category.toJson();
      expect(json['id'], 'cat-1');
      expect(json['name'], 'Work');
      expect(json['colorValue'], 0xFF4CAF50);

      final deserialized = Category.fromJson(json);
      expect(deserialized.id, category.id);
      expect(deserialized.name, category.name);
      expect(deserialized.colorValue, category.colorValue);
    });

    test('Task serialization and deserialization', () {
      final dueDate = DateTime(2026, 7, 6, 11, 0);
      final startTime = DateTime(2026, 7, 6, 9, 30);
      final task = Task(
        id: 'task-1',
        title: 'Complete Coding Tasks',
        dueDate: dueDate,
        startTime: startTime,
        priority: TaskPriority.high,
        categoryId: 'cat-1',
        isCompleted: true,
        has30MinReminder: true,
        hasStartReminder: true,
      );

      final json = task.toJson();
      expect(json['id'], 'task-1');
      expect(json['title'], 'Complete Coding Tasks');
      expect(json['dueDate'], dueDate.toIso8601String());
      expect(json['startTime'], startTime.toIso8601String());
      expect(json['priority'], 'high');
      expect(json['categoryId'], 'cat-1');
      expect(json['isCompleted'], true);
      expect(json['has30MinReminder'], true);
      expect(json['hasStartReminder'], true);

      final deserialized = Task.fromJson(json);
      expect(deserialized.id, task.id);
      expect(deserialized.title, task.title);
      expect(deserialized.dueDate, task.dueDate);
      expect(deserialized.startTime, task.startTime);
      expect(deserialized.priority, task.priority);
      expect(deserialized.categoryId, task.categoryId);
      expect(deserialized.isCompleted, task.isCompleted);
      expect(deserialized.has30MinReminder, task.has30MinReminder);
      expect(deserialized.hasStartReminder, task.hasStartReminder);
    });

    test('Note serialization and deserialization', () {
      final modifiedTime = DateTime(2026, 7, 6, 12, 0, 0);
      final note = Note(
        id: 'note-1',
        title: 'Code Ideas',
        content: 'Write unit tests first.',
        categoryId: 'cat-1',
        modifiedTime: modifiedTime,
        isPinned: true,
      );

      final json = note.toJson();
      expect(json['id'], 'note-1');
      expect(json['title'], 'Code Ideas');
      expect(json['content'], 'Write unit tests first.');
      expect(json['categoryId'], 'cat-1');
      expect(json['modifiedTime'], modifiedTime.toIso8601String());
      expect(json['isPinned'], true);

      final deserialized = Note.fromJson(json);
      expect(deserialized.id, note.id);
      expect(deserialized.title, note.title);
      expect(deserialized.content, note.content);
      expect(deserialized.categoryId, note.categoryId);
      expect(deserialized.modifiedTime, note.modifiedTime);
      expect(deserialized.isPinned, note.isPinned);
    });
  });

  group('Date Utility Tests', () {
    test('AppDateUtils calculations', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day, 12, 0);
      final tomorrow = today.add(const Duration(days: 1));
      final yesterday = today.subtract(const Duration(days: 1));

      expect(AppDateUtils.isToday(today), true);
      expect(AppDateUtils.isToday(tomorrow), false);
      expect(AppDateUtils.isTomorrow(tomorrow), true);
      expect(AppDateUtils.isTomorrow(today), false);

      // Overdue is true if date is yesterday and not completed
      expect(AppDateUtils.isOverdue(yesterday, false), true);
      // Overdue is false if completed
      expect(AppDateUtils.isOverdue(yesterday, true), false);
      // Overdue is false if date is today or future
      expect(AppDateUtils.isOverdue(today, false), false);
      expect(AppDateUtils.isOverdue(tomorrow, false), false);

      // Night calculation (>= 18 or < 6)
      final daytime = DateTime(2026, 7, 22, 10, 0);
      final nighttime1 = DateTime(2026, 7, 22, 20, 0);
      final nighttime2 = DateTime(2026, 7, 22, 2, 0);

      expect(AppDateUtils.isNight(daytime), false);
      expect(AppDateUtils.isNight(nighttime1), true);
      expect(AppDateUtils.isNight(nighttime2), true);

      // Time formatting & range string
      final t1 = DateTime(2026, 7, 22, 9, 30);
      final t2 = DateTime(2026, 7, 22, 14, 15);
      expect(AppDateUtils.formatTime(t1), '9:30 AM');
      expect(AppDateUtils.formatTime(t2), '2:15 PM');

      final timeRangeStr = AppDateUtils.getFriendlyTimeRangeString(dueDate: t2, startTime: t1);
      expect(timeRangeStr, contains('9:30 AM - 2:15 PM'));
    });
  });

  group('State Providers CRUD & Cache Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    test('CategoriesProvider operations', () async {
      final provider = CategoriesProvider();
      await Future.delayed(const Duration(milliseconds: 150));

      // Should contain default category (General, Work, etc.)
      expect(provider.categories.isNotEmpty, true);
      final initialCount = provider.categories.length;

      // Add category
      final newCat = Category(id: 'test-cat', name: 'Leisure', colorValue: 0xFF9C27B0);
      provider.addCategory(newCat);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(provider.categories.length, initialCount + 1);
      expect(provider.getCategoryById('test-cat').name, 'Leisure');

      // Verify persistence saving
      final savedStr = prefs.getString('custom_categories');
      expect(savedStr, isNotNull);
      expect(savedStr!.contains('Leisure'), true);
    });

    test('TasksProvider operations', () async {
      final provider = TasksProvider();
      await Future.delayed(const Duration(milliseconds: 150));

      // Initially contains default tasks
      expect(provider.tasks.isNotEmpty, true);
      final initialCount = provider.tasks.length;

      // Add Task
      final task = Task(
        id: 't-1',
        title: 'Buy Milk',
        dueDate: DateTime.now(),
        categoryId: 'cat-general',
      );
      provider.addTask(task);
      expect(provider.tasks.length, initialCount + 1);

      // Toggle Task
      provider.toggleTaskCompletion('t-1');
      expect(provider.tasks.firstWhere((t) => t.id == 't-1').isCompleted, true);

      // Delete Task
      final deleted = provider.deleteTask('t-1');
      expect(provider.tasks.length, initialCount);
      expect(deleted?.title, 'Buy Milk');

      // Undo deletion
      provider.insertTask(provider.tasks.length, deleted!);
      expect(provider.tasks.length, initialCount + 1);
      expect(provider.tasks.last.title, 'Buy Milk');

      // Verify persistence key
      final savedStr = prefs.getString('custom_tasks');
      expect(savedStr, isNotNull);
    });

    test('NotesProvider operations', () async {
      final provider = NotesProvider();
      await Future.delayed(const Duration(milliseconds: 150));

      // Initially contains default notes
      expect(provider.notes.isNotEmpty, true);
      final initialCount = provider.notes.length;

      // Add Note
      final note = Note(
        id: 'n-1',
        title: 'Meeting Notes',
        content: 'Review roadmap.',
        categoryId: 'cat-general',
        modifiedTime: DateTime.now(),
      );
      provider.addNote(note);
      expect(provider.notes.length, initialCount + 1);

      // Toggle Pin
      provider.toggleNotePin('n-1');
      expect(provider.notes.firstWhere((n) => n.id == 'n-1').isPinned, true);

      // Delete note
      final deleted = provider.deleteNote('n-1');
      expect(provider.notes.length, initialCount);
      expect(deleted?.title, 'Meeting Notes');

      // Undo note deletion
      provider.insertNote(provider.notes.length, deleted!);
      expect(provider.notes.length, initialCount + 1);

      // Verify persistence key
      final savedStr = prefs.getString('custom_notes');
      expect(savedStr, isNotNull);
    });

    test('SettingsProvider operations', () async {
      final provider = SettingsProvider();
      await Future.delayed(const Duration(milliseconds: 150));

      // Defaults
      expect(provider.soundEffectsEnabled, true);

      // Toggle sound
      await provider.toggleSoundEffects(false);
      expect(provider.soundEffectsEnabled, false);
      expect(prefs.getBool('sound_effects_enabled'), false);
    });

    test('Recurring task auto-spawning on completion', () async {
      final provider = TasksProvider();
      await Future.delayed(const Duration(milliseconds: 150));

      final initialCount = provider.tasks.length;
      final startDate = DateTime(2026, 7, 26, 9, 0);

      final recurringTask = Task(
        id: 'rec-1',
        title: 'Daily Standup',
        dueDate: startDate,
        recurrence: RecurrenceType.daily,
      );

      provider.addTask(recurringTask);
      expect(provider.tasks.length, initialCount + 1);

      // Complete the recurring task
      provider.toggleTaskCompletion('rec-1');

      // The original task should be completed
      final original = provider.tasks.firstWhere((t) => t.id == 'rec-1');
      expect(original.isCompleted, true);

      // A new task instance should be created for tomorrow
      expect(provider.tasks.length, initialCount + 2);
      final spawnedTask = provider.tasks.last;
      expect(spawnedTask.isCompleted, false);
      expect(spawnedTask.title, 'Daily Standup');
      expect(spawnedTask.recurrence, RecurrenceType.daily);
      expect(spawnedTask.dueDate, startDate.add(const Duration(days: 1)));
    });

    test('Recurrence date calculations in AppDateUtils', () {
      final start = DateTime(2026, 7, 26, 10, 0);

      final dailyNext = AppDateUtils.getNextOccurrence(start, RecurrenceType.daily);
      expect(dailyNext, DateTime(2026, 7, 27, 10, 0));

      final weeklyNext = AppDateUtils.getNextOccurrence(start, RecurrenceType.weekly);
      expect(weeklyNext, DateTime(2026, 8, 2, 10, 0));

      final monthlyNext = AppDateUtils.getNextOccurrence(start, RecurrenceType.monthly);
      expect(monthlyNext, DateTime(2026, 8, 26, 10, 0));

      expect(AppDateUtils.getRecurrenceLabel(RecurrenceType.daily), 'Daily');
      expect(AppDateUtils.getRecurrenceLabel(RecurrenceType.weekly), 'Weekly');
      expect(AppDateUtils.getRecurrenceLabel(RecurrenceType.monthly), 'Monthly');
      expect(AppDateUtils.getRecurrenceLabel(RecurrenceType.none), 'Does not repeat');
    });
  });
}

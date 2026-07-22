import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/features/categories/application/categories_provider.dart';
import 'package:tudu/features/tasks/business/models/task_model.dart';
import 'package:tudu/features/tasks/application/tasks_provider.dart';
import 'package:tudu/features/tasks/presentation/widgets/task_tile.dart';
import 'package:tudu/features/notes/business/models/note_model.dart';
import 'package:tudu/features/notes/application/notes_provider.dart';
import 'package:tudu/features/notes/presentation/widgets/note_card.dart';
import 'package:tudu/features/settings/application/settings_provider.dart';
import 'package:tudu/shared/widgets/sun_moon_transition_icon.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TaskTile Widget Tests', () {
    late TasksProvider tasksProvider;
    late CategoriesProvider categoriesProvider;
    late SettingsProvider settingsProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      tasksProvider = TasksProvider();
      categoriesProvider = CategoriesProvider();
      settingsProvider = SettingsProvider();

      await Future.delayed(const Duration(milliseconds: 150));
    });

    testWidgets('Renders task title, category label and priority', (WidgetTester tester) async {
      final task = Task(
        id: 't-test',
        title: 'Review PRs',
        dueDate: DateTime.now(),
        categoryId: 'cat-general', // General is default seeded category ID
        priority: TaskPriority.high,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TasksProvider>.value(value: tasksProvider),
            ChangeNotifierProvider<CategoriesProvider>.value(value: categoriesProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TaskTile(task: task, swipeable: false),
            ),
          ),
        ),
      );

      // Verify title is rendered
      expect(find.text('Review PRs'), findsOneWidget);

      // Verify category 'General' is rendered
      expect(find.text('General'), findsOneWidget);

      // Verify priority text is rendered (formatted as first letter capitalized)
      expect(find.text('High'), findsOneWidget);
    });

    testWidgets('Tapping checkbox calls toggleTaskCompletion', (WidgetTester tester) async {
      final task = Task(
        id: 't-test',
        title: 'Send Report',
        dueDate: DateTime.now(),
        categoryId: 'cat-general',
      );
      tasksProvider.addTask(task);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TasksProvider>.value(value: tasksProvider),
            ChangeNotifierProvider<CategoriesProvider>.value(value: categoriesProvider),
            ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TaskTile(task: task, swipeable: false),
            ),
          ),
        ),
      );

      // Verify initial checkbox value is unchecked
      final Checkbox checkbox = tester.widget(find.byType(Checkbox));
      expect(checkbox.value, false);

      // Tap checkbox
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      // Verify task completion is toggled in provider
      expect(tasksProvider.tasks.firstWhere((t) => t.id == 't-test').isCompleted, true);
    });
  });

  group('NoteCard Widget Tests', () {
    late NotesProvider notesProvider;
    late CategoriesProvider categoriesProvider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      notesProvider = NotesProvider();
      categoriesProvider = CategoriesProvider();

      await Future.delayed(const Duration(milliseconds: 150));
    });

    testWidgets('Renders note title, preview content and pin status', (WidgetTester tester) async {
      final note = Note(
        id: 'n-test',
        title: 'Shopping List',
        content: 'Apples, bananas, and cherries.',
        categoryId: 'cat-general',
        modifiedTime: DateTime.now(),
        isPinned: true,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<NotesProvider>.value(value: notesProvider),
            ChangeNotifierProvider<CategoriesProvider>.value(value: categoriesProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 300,
                width: 300,
                child: NoteCard(note: note, swipeable: false),
              ),
            ),
          ),
        ),
      );

      // Verify title and content preview
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Apples, bananas, and cherries.'), findsOneWidget);

      // Verify Category name 'General'
      expect(find.text('General'), findsOneWidget);

      // Verify pin icon status represents note.isPinned (push_pin)
      final Icon pinIcon = tester.widget(find.byIcon(Icons.push_pin));
      expect(pinIcon.color, isNotNull);
    });
  });

  group('SunMoonTransitionIcon Widget Tests', () {
    testWidgets('Renders sun icon when isNightOverride is false', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SunMoonTransitionIcon(isNightOverride: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);
      expect(find.byIcon(Icons.nights_stay_rounded), findsNothing);
    });

    testWidgets('Renders moon icon when isNightOverride is true', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SunMoonTransitionIcon(isNightOverride: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.nights_stay_rounded), findsOneWidget);
      expect(find.byIcon(Icons.wb_sunny_rounded), findsNothing);
    });

    testWidgets('Tapping icon triggers animated transition between sun and moon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SunMoonTransitionIcon(isNightOverride: false),
          ),
        ),
      );

      expect(find.byIcon(Icons.wb_sunny_rounded), findsOneWidget);

      // Tap icon to switch preview mode
      await tester.tap(find.byType(SunMoonTransitionIcon));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.nights_stay_rounded), findsOneWidget);
    });
  });
}

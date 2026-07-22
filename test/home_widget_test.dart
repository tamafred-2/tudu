import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/features/tasks/business/models/task_model.dart';
import 'package:tudu/shared/services/home_widget_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeWidgetService Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('updateWidgetData formats today pending tasks and payload correctly', () async {
      final now = DateTime.now();
      final tasks = [
        Task(
          id: 't1',
          title: 'Buy Groceries',
          dueDate: now,
          isCompleted: false,
        ),
        Task(
          id: 't2',
          title: 'Read 20 pages',
          dueDate: now,
          isCompleted: false,
        ),
        Task(
          id: 't3',
          title: 'Completed Task',
          dueDate: now,
          isCompleted: true,
        ),
      ];

      final data = await HomeWidgetService.updateWidgetData(tasks);

      expect(data.pendingCount, 2);
      expect(data.completedCount, 1);
      expect(data.topTaskTitles, contains('Buy Groceries'));
      expect(data.topTaskTitles, contains('Read 20 pages'));

      final cached = await HomeWidgetService.getWidgetData();
      expect(cached, isNotNull);
      expect(cached?.pendingCount, 2);
      expect(cached?.completedCount, 1);
    });
  });
}

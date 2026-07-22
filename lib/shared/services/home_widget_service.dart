import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/tasks/business/models/task_model.dart';
import '../utils/date_utils.dart';

class HomeWidgetData {
  final int pendingCount;
  final int completedCount;
  final List<String> topTaskTitles;
  final String lastUpdated;

  const HomeWidgetData({
    required this.pendingCount,
    required this.completedCount,
    required this.topTaskTitles,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
        'pendingCount': pendingCount,
        'completedCount': completedCount,
        'topTaskTitles': topTaskTitles,
        'lastUpdated': lastUpdated,
      };

  factory HomeWidgetData.fromJson(Map<String, dynamic> json) => HomeWidgetData(
        pendingCount: json['pendingCount'] as int? ?? 0,
        completedCount: json['completedCount'] as int? ?? 0,
        topTaskTitles: (json['topTaskTitles'] as List<dynamic>?)?.cast<String>() ?? [],
        lastUpdated: json['lastUpdated'] as String? ?? '',
      );
}

class HomeWidgetService {
  static const String keyWidgetData = 'tudu_home_widget_data';
  static const String keyPendingCount = 'widget_pending_count';
  static const String keyCompletedCount = 'widget_completed_count';
  static const String keyTopTasks = 'widget_top_tasks';

  /// Synchronizes tasks to local storage for the native Android AppWidget to read.
  static Future<HomeWidgetData> updateWidgetData(List<Task> allTasks) async {
    try {
      // Filter tasks due today or overdue
      final todayTasks = allTasks.where((task) {
        return AppDateUtils.isToday(task.dueDate) ||
            AppDateUtils.isOverdue(task.dueDate, task.isCompleted);
      }).toList();

      // Sort: pending first, then by due date
      todayTasks.sort((a, b) {
        if (a.isCompleted != b.isCompleted) {
          return a.isCompleted ? 1 : -1;
        }
        return a.dueDate.compareTo(b.dueDate);
      });

      final pendingTasks = todayTasks.where((t) => !t.isCompleted).toList();
      final completedCount = todayTasks.where((t) => t.isCompleted).length;
      final topTitles = pendingTasks.take(3).map((t) => t.title).toList();

      final now = DateTime.now();
      final timeStr = AppDateUtils.formatTime(now);

      final widgetData = HomeWidgetData(
        pendingCount: pendingTasks.length,
        completedCount: completedCount,
        topTaskTitles: topTitles,
        lastUpdated: timeStr,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyWidgetData, jsonEncode(widgetData.toJson()));
      await prefs.setInt(keyPendingCount, pendingTasks.length);
      await prefs.setInt(keyCompletedCount, completedCount);
      await prefs.setString(keyTopTasks, topTitles.join('\n'));

      debugPrint('HomeWidgetData updated: ${pendingTasks.length} pending tasks');
      return widgetData;
    } catch (e) {
      debugPrint('Failed to update HomeWidgetData: $e');
      return const HomeWidgetData(
        pendingCount: 0,
        completedCount: 0,
        topTaskTitles: [],
        lastUpdated: '',
      );
    }
  }

  /// Retrieves the latest cached widget data
  static Future<HomeWidgetData?> getWidgetData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(keyWidgetData);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        return HomeWidgetData.fromJson(jsonDecode(jsonStr));
      }
    } catch (e) {
      debugPrint('Failed to read HomeWidgetData: $e');
    }
    return null;
  }
}

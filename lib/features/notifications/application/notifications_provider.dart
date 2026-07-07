import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';
import '../../tasks/application/tasks_provider.dart';
import '../../../shared/utils/date_utils.dart';

class NotificationsProvider with ChangeNotifier {
  bool _isDailyReminderEnabled = false;
  int _reminderHour = 9; // Default 09:00 AM
  int _reminderMinute = 0;
  String _lastSentDate = '';
  Timer? _reminderTimer;

  NotificationsProvider() {
    _loadNotificationSettings();
  }

  bool get isDailyReminderEnabled => _isDailyReminderEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDailyReminderEnabled = prefs.getBool('is_daily_reminder_enabled') ?? false;
      _reminderHour = prefs.getInt('reminder_hour') ?? 9;
      _reminderMinute = prefs.getInt('reminder_minute') ?? 0;
      _lastSentDate = prefs.getString('last_sent_date') ?? '';
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load notification settings: $e');
    }
  }

  Future<void> toggleDailyReminder(bool value) async {
    _isDailyReminderEnabled = value;
    if (value) {
      // Request permission immediately when enabling
      NotificationService.instance.requestPermission();
    }
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_daily_reminder_enabled', value);
    } catch (e) {
      debugPrint('Failed to save daily reminder status: $e');
    }
  }

  Future<void> updateReminderTime(int hour, int minute) async {
    _reminderHour = hour;
    _reminderMinute = minute;
    // Reset last sent date so it can trigger for the new time today if not already passed
    _lastSentDate = '';
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', hour);
      await prefs.setInt('reminder_minute', minute);
      await prefs.setString('last_sent_date', '');
    } catch (e) {
      debugPrint('Failed to save reminder time: $e');
    }
  }

  TasksProvider? _tasksProvider;

  void startReminderTimer(TasksProvider tasksProvider) {
    _tasksProvider = tasksProvider;
    _reminderTimer ??= Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_tasksProvider != null) {
        _checkAndSendReminder(_tasksProvider!);
      }
    });
  }

  void _checkAndSendReminder(TasksProvider tasksProvider) {
    if (!_isDailyReminderEnabled) return;

    final now = DateTime.now();
    if (now.hour == _reminderHour && now.minute == _reminderMinute) {
      final todayString = '${now.year}-${now.month}-${now.day}';
      if (_lastSentDate != todayString) {
        _lastSentDate = todayString;
        SharedPreferences.getInstance().then((prefs) {
          prefs.setString('last_sent_date', todayString);
        }).catchError((e) {
          debugPrint('Failed to save last sent date: $e');
        });

        // Count pending tasks due today or overdue
        final pendingCount = tasksProvider.tasks.where((task) {
          return !task.isCompleted &&
              (AppDateUtils.isToday(task.dueDate) || AppDateUtils.isOverdue(task.dueDate, task.isCompleted));
        }).length;

        if (pendingCount > 0) {
          NotificationService.instance.showNotification(
            'Daily Tasks Reminder 📅',
            'You have $pendingCount pending task(s) to check off today!',
          );
        } else {
          NotificationService.instance.showNotification(
            'Daily Tasks Reminder 📅',
            'All caught up! No tasks left for today. Have a great day!',
          );
        }
      }
    }
  }

  void sendTestNotification() {
    NotificationService.instance.showNotification(
      'Tudu Test Notification 🔔',
      'It works! Local notifications are fully configured.',
    );
  }

  @override
  void dispose() {
    _reminderTimer?.cancel();
    super.dispose();
  }
}

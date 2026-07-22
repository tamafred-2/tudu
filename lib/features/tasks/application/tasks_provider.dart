import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../business/models/task_model.dart';

import '../../../shared/services/home_widget_service.dart';

class TasksProvider with ChangeNotifier {
  final List<Task> _tasks = [];

  TasksProvider() {
    _loadTasks();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> _loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? tasksJson = prefs.getString('custom_tasks');
      if (tasksJson != null) {
        final List<dynamic> decodedList = jsonDecode(tasksJson) as List<dynamic>;
        _tasks.clear();
        _tasks.addAll(decodedList.map((item) => Task.fromJson(item as Map<String, dynamic>)));
      } else {
        _loadInitialTasks();
        _saveTasks();
      }
    } catch (e) {
      debugPrint('Failed to load tasks: $e');
      _loadInitialTasks();
    } finally {
      HomeWidgetService.updateWidgetData(_tasks);
      notifyListeners();
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String tasksJson = jsonEncode(_tasks.map((t) => t.toJson()).toList());
      await prefs.setString('custom_tasks', tasksJson);
      HomeWidgetService.updateWidgetData(_tasks);
    } catch (e) {
      debugPrint('Failed to save tasks: $e');
    }
  }

  void _loadInitialTasks() {
    _tasks.add(
      Task(
        id: '1',
        title: 'Welcome! Tap the circle to complete me ✅',
        categoryId: 'general',
        dueDate: DateTime.now(),
        isCompleted: false,
        priority: TaskPriority.medium,
      ),
    );
  }

  // Add a task
  void addTask(Task task) {
    _tasks.add(task);
    notifyListeners();
    _saveTasks();
  }

  // Insert a task at a specific index (used for Undo functionality)
  void insertTask(int index, Task task) {
    if (index >= 0 && index <= _tasks.length) {
      _tasks.insert(index, task);
      notifyListeners();
      _saveTasks();
    }
  }

  // Toggle completion
  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(isCompleted: !_tasks[index].isCompleted);
      notifyListeners();
      _saveTasks();
    }
  }

  // Delete a task and return it (for undo)
  Task? deleteTask(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks.removeAt(index);
      notifyListeners();
      _saveTasks();
      return task;
    }
    return null;
  }

  // Get index of a task by id
  int getTaskIndex(String id) {
    return _tasks.indexWhere((t) => t.id == id);
  }

  // Edit a task
  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      notifyListeners();
      _saveTasks();
    }
  }
}

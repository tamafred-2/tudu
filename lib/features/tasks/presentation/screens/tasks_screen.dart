import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/models/task_model.dart';
import '../../application/tasks_provider.dart';
import 'package:tudu/features/search/presentation/widgets/task_search_delegate.dart';
import 'package:tudu/shared/utils/date_utils.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/task_tile.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

abstract class TasksListItem {}

class TasksHeaderItem implements TasksListItem {
  final String heading;
  TasksHeaderItem(this.heading);
}

class TasksTaskItem implements TasksListItem {
  final Task task;
  TasksTaskItem(this.task);
}

class _TasksScreenState extends State<TasksScreen> {
  String _selectedFilter = 'Pending';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksProvider = Provider.of<TasksProvider>(context);
    final allTasks = tasksProvider.tasks;

    // Filter tasks based on selected filter
    final filteredTasks = allTasks.where((task) {
      if (_selectedFilter == 'Pending') {
        return !task.isCompleted;
      } else if (_selectedFilter == 'Completed') {
        return task.isCompleted;
      }
      return true; // 'All'
    }).toList();

    // Categorize tasks into chronological groups
    final overdueTasks = filteredTasks.where((task) => AppDateUtils.isOverdue(task.dueDate, task.isCompleted)).toList();
    final todayTasks = filteredTasks.where((task) => AppDateUtils.isToday(task.dueDate) && !AppDateUtils.isOverdue(task.dueDate, task.isCompleted)).toList();
    final tomorrowTasks = filteredTasks.where((task) => AppDateUtils.isTomorrow(task.dueDate) && !AppDateUtils.isOverdue(task.dueDate, task.isCompleted)).toList();
    final upcomingTasks = filteredTasks.where((task) => !AppDateUtils.isOverdue(task.dueDate, task.isCompleted) && !AppDateUtils.isToday(task.dueDate) && !AppDateUtils.isTomorrow(task.dueDate)).toList();

    // Sort function for details in sub-groups
    int taskSorter(Task a, Task b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final dateCompare = a.dueDate.compareTo(b.dueDate);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return b.priority.index.compareTo(a.priority.index);
    }

    overdueTasks.sort(taskSorter);
    todayTasks.sort(taskSorter);
    tomorrowTasks.sort(taskSorter);
    upcomingTasks.sort(taskSorter);

    // Build mixed headers/tasks flat list
    final List<TasksListItem> listItems = [];
    if (overdueTasks.isNotEmpty) {
      listItems.add(TasksHeaderItem('Overdue'));
      listItems.addAll(overdueTasks.map((t) => TasksTaskItem(t)));
    }
    if (todayTasks.isNotEmpty) {
      listItems.add(TasksHeaderItem('Today'));
      listItems.addAll(todayTasks.map((t) => TasksTaskItem(t)));
    }
    if (tomorrowTasks.isNotEmpty) {
      listItems.add(TasksHeaderItem('Tomorrow'));
      listItems.addAll(tomorrowTasks.map((t) => TasksTaskItem(t)));
    }
    if (upcomingTasks.isNotEmpty) {
      listItems.add(TasksHeaderItem('Upcoming'));
      listItems.addAll(upcomingTasks.map((t) => TasksTaskItem(t)));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tip: Swipe a task to delete it.'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _selectedFilter == 'All',
                  onTap: () => setState(() => _selectedFilter = 'All'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  selected: _selectedFilter == 'Pending',
                  onTap: () => setState(() => _selectedFilter = 'Pending'),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Completed',
                  selected: _selectedFilter == 'Completed',
                  onTap: () => setState(() => _selectedFilter = 'Completed'),
                ),
              ],
            ),
          ),
          
          // Tasks List (Dynamic)
          Expanded(
            child: filteredTasks.isEmpty
                ? _buildEmptyState(context)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: listItems.length,
                    itemBuilder: (context, index) {
                      final item = listItems[index];
                      if (item is TasksHeaderItem) {
                        final isOverdueHeader = item.heading == 'Overdue';
                        return Padding(
                          padding: const EdgeInsets.only(top: 16.0, bottom: 8.0, left: 8.0),
                          child: Text(
                            item.heading,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isOverdueHeader ? theme.colorScheme.error : theme.colorScheme.primary,
                              letterSpacing: 1.0,
                            ),
                          ),
                        );
                      } else if (item is TasksTaskItem) {
                        return TaskTile(task: item.task);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => const AddTaskSheet(),
          );
        },
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    String title;
    String subtitle;

    if (_selectedFilter == 'Completed') {
      icon = Icons.check_circle_outline;
      title = 'No completed tasks';
      subtitle = 'Complete some tasks to see them here!';
    } else if (_selectedFilter == 'Pending') {
      icon = Icons.done_all;
      title = 'All caught up!';
      subtitle = 'You have completed all of your tasks.';
    } else {
      icon = Icons.assignment_outlined;
      title = 'Your task list is empty';
      subtitle = 'Tap the + button to create a new task.';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.secondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

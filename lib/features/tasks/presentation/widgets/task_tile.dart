import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/models/task_model.dart';
import '../../application/tasks_provider.dart';
import '../../../categories/application/categories_provider.dart';
import '../../../settings/application/settings_provider.dart';
import '../../../../shared/services/audio_service.dart';
import '../../../../shared/utils/date_utils.dart';
import 'edit_task_sheet.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final bool swipeable;
  final VoidCallback? onToggled;

  const TaskTile({
    super.key,
    required this.task,
    this.swipeable = true,
    this.onToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOverdue = AppDateUtils.isOverdue(task.dueDate, task.isCompleted);
    final friendlyDate = AppDateUtils.getFriendlyDateString(task.dueDate);
    final dateColor = isOverdue ? theme.colorScheme.error : theme.colorScheme.onSurfaceVariant;
    
    final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
    final categoriesProvider = Provider.of<CategoriesProvider>(context, listen: false);
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    final category = categoriesProvider.getCategoryById(task.categoryId);

    Widget buildCardContent(BuildContext context) {
      return Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => EditTaskSheet(task: task),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Checkbox(
                  value: task.isCompleted,
                  onChanged: (val) {
                    if (!task.isCompleted && settingsProvider.soundEffectsEnabled) {
                      AudioService.instance.playSuccessChime();
                    }
                    tasksProvider.toggleTaskCompletion(task.id);
                    if (onToggled != null) {
                      onToggled!();
                    }
                  },
                  activeColor: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: theme.textTheme.bodyLarge!.copyWith(
                          decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                          color: task.isCompleted ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5) : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        child: Text(task.title),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Color(category.colorValue).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              category.name,
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 10,
                                color: Color(category.colorValue),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.calendar_today,
                            size: 10,
                            color: dateColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            friendlyDate,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: dateColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(task.priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            task.priority.name[0].toUpperCase() + task.priority.name.substring(1),
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!swipeable) {
      return buildCardContent(context);
    }

    return Dismissible(
      key: Key(task.id),
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.red),
      ),
      onDismissed: (direction) {
        final taskIndex = tasksProvider.getTaskIndex(task.id);
        final deletedTask = tasksProvider.deleteTask(task.id);
        
        if (deletedTask != null) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task "${task.title}" deleted'),
              action: SnackBarAction(
                label: 'Undo',
                onPressed: () {
                  tasksProvider.insertTask(taskIndex, deletedTask);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
              duration: const Duration(milliseconds: 2500),
            ),
          );
        }
      },
      child: buildCardContent(context),
    );
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Colors.red.shade400;
      case TaskPriority.medium:
        return Colors.orange.shade400;
      case TaskPriority.low:
        return Colors.blue.shade400;
    }
  }
}

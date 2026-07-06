import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../tasks/application/tasks_provider.dart';
import '../../../categories/application/categories_provider.dart';
import '../../../tasks/presentation/widgets/task_tile.dart';

class TaskSearchDelegate extends SearchDelegate<void> {
  TaskSearchDelegate()
      : super(
          searchFieldLabel: 'Search tasks...',
        );

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            query = '';
          },
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResultList(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResultList(context);
  }

  Widget _buildSearchResultList(BuildContext context) {
    final theme = Theme.of(context);
    final search = query.trim().toLowerCase();

    return Consumer2<TasksProvider, CategoriesProvider>(
      builder: (context, tasksProvider, categoriesProvider, child) {
        final allTasks = tasksProvider.tasks;
        final filteredTasks = allTasks.where((task) {
          return task.title.toLowerCase().contains(search);
        }).toList();

        // Sort: pending first, then sort by due date, then by priority
        filteredTasks.sort((a, b) {
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          final dateCompare = a.dueDate.compareTo(b.dueDate);
          if (dateCompare != 0) {
            return dateCompare;
          }
          return b.priority.index.compareTo(a.priority.index);
        });

        if (filteredTasks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No matching tasks',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Try checking your spelling or search for something else.',
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

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          itemCount: filteredTasks.length,
          itemBuilder: (context, index) {
            final task = filteredTasks[index];
            return TaskTile(
              task: task,
              swipeable: false,
              onToggled: () {
                query = query;
              },
            );
          },
        );
      },
    );
  }
}

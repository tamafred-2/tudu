import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'package:tudu/features/tasks/application/tasks_provider.dart';
import 'package:tudu/features/tasks/presentation/widgets/add_task_sheet.dart';
import 'package:tudu/features/notes/presentation/widgets/note_editor_sheet.dart';
import 'package:tudu/features/categories/presentation/widgets/category_manager_sheet.dart';
import 'package:tudu/features/tasks/presentation/widgets/task_tile.dart';
import 'package:tudu/shared/utils/date_utils.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  int _quoteIndex = 0;

  final List<Map<String, String>> _quotes = [
    {
      'quote': 'Focus on being productive instead of busy.',
      'author': 'Tim Ferriss',
    },
    {
      'quote': 'The secret of getting ahead is getting started.',
      'author': 'Mark Twain',
    },
    {
      'quote': 'Action is the foundational key to all success.',
      'author': 'Pablo Picasso',
    },
    {
      'quote': 'It is not that we have a short time to live, but that we waste a lot of it.',
      'author': 'Seneca',
    },
    {
      'quote': 'Very little is needed to make a happy life; it is all within yourself.',
      'author': 'Marcus Aurelius',
    },
    {
      'quote': 'Simplicity is the ultimate sophistication.',
      'author': 'Leonardo da Vinci',
    },
    {
      'quote': 'Your mind is for having ideas, not holding them.',
      'author': 'David Allen',
    },
    {
      'quote': 'Make each day your masterpiece.',
      'author': 'John Wooden',
    },
  ];

  @override
  void initState() {
    super.initState();
    // Choose a random quote on startup
    _quoteIndex = Random().nextInt(_quotes.length);
  }

  void _shuffleQuote() {
    setState(() {
      _quoteIndex = (_quoteIndex + 1) % _quotes.length;
    });
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 18) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final weekdays = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final weekday = weekdays[now.weekday % 7];
    final month = months[now.month - 1];
    return '$weekday, $month ${now.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tasksProvider = Provider.of<TasksProvider>(context);
    final allTasks = tasksProvider.tasks;

    // Filter tasks due today or overdue
    final todayTasks = allTasks.where((task) {
      return AppDateUtils.isToday(task.dueDate) || AppDateUtils.isOverdue(task.dueDate, task.isCompleted);
    }).toList();

    // Sort: pending first, then sort by due date, then by priority
    todayTasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      final dateCompare = a.dueDate.compareTo(b.dueDate);
      if (dateCompare != 0) {
        return dateCompare;
      }
      return b.priority.index.compareTo(a.priority.index);
    });

    final totalTodayCount = todayTasks.length;
    final completedTodayCount = todayTasks.where((task) => task.isCompleted).length;
    final pendingTodayCount = totalTodayCount - completedTodayCount;
    final double progressValue = totalTodayCount > 0 ? completedTodayCount / totalTodayCount : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dynamic Welcome Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, User!',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFormattedDate(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.wb_sunny,
                  size: 40,
                  color: Colors.amber.shade600,
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Motivational Quote Box
            Card(
              elevation: 0,
              color: theme.colorScheme.primaryContainer.withValues(alpha: 0.25),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.15),
                                end: Offset.zero,
                              ).animate(animation),
                              child: child,
                            ),
                          );
                        },
                        child: Column(
                          key: ValueKey<int>(_quoteIndex),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _quotes[_quoteIndex]['quote']!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '— ${_quotes[_quoteIndex]['author']}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, size: 16),
                      onPressed: _shuffleQuote,
                      tooltip: 'Next Quote',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Dynamic Stats Grid
            Row(
              children: [
                // Completed Card
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          Text(
                            '$completedTodayCount',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Completed',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Pending Card
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          Text(
                            '$pendingTodayCount',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.secondary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Pending',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Progress Card
                Expanded(
                  child: Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  value: progressValue,
                                  strokeWidth: 4,
                                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(progressValue * 100).toInt()}%',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Daily Progress',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Actions Panel
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Add Task Action
                Expanded(
                  child: OutlinedButton.icon(
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
                    icon: const Icon(Icons.add_task),
                    label: const Text('Add Task'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Add Note Action
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const NoteEditorSheet()),
                      );
                    },
                    icon: const Icon(Icons.note_add_outlined),
                    label: const Text('New Note'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Categories Shortcut
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const CategoryManagerSheet()),
                      );
                    },
                    icon: const Icon(Icons.label_outline),
                    label: const Text('Labels'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Highlights List
            Text(
              "Today's Highlights",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            // Dynamic Highlights Tasks List
            todayTasks.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.wb_sunny_outlined,
                            size: 48,
                            color: theme.colorScheme.secondary.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No tasks due today!',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Enjoy your day or create a new task.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: todayTasks.length,
                    itemBuilder: (context, index) {
                      final task = todayTasks[index];
                      return TaskTile(task: task, swipeable: false);
                    },
                  ),
          ],
        ),
      ),
    );
  }


}

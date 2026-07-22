import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../business/models/task_model.dart';
import '../../application/tasks_provider.dart';
import '../../../categories/application/categories_provider.dart';

class EditTaskSheet extends StatefulWidget {
  final Task task;

  const EditTaskSheet({super.key, required this.task});

  @override
  State<EditTaskSheet> createState() => _EditTaskSheetState();
}

class _EditTaskSheetState extends State<EditTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  
  late String _selectedCategoryId;
  late TaskPriority _selectedPriority;
  late DateTime _selectedDate;

  late bool _hasTimeRange;
  late TimeOfDay _startTimeOfDay;
  late TimeOfDay _endTimeOfDay;
  late bool _has30MinReminder;
  late bool _hasStartReminder;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.task.title;
    _selectedCategoryId = widget.task.categoryId;
    _selectedPriority = widget.task.priority;
    _selectedDate = widget.task.dueDate;

    _hasTimeRange = widget.task.startTime != null;
    if (widget.task.startTime != null) {
      _startTimeOfDay = TimeOfDay.fromDateTime(widget.task.startTime!);
      _endTimeOfDay = TimeOfDay.fromDateTime(widget.task.dueDate);
    } else {
      _startTimeOfDay = const TimeOfDay(hour: 9, minute: 0);
      _endTimeOfDay = const TimeOfDay(hour: 10, minute: 0);
    }

    _has30MinReminder = widget.task.has30MinReminder;
    _hasStartReminder = widget.task.hasStartReminder;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final initial = isStart ? _startTimeOfDay : _endTimeOfDay;
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTimeOfDay = picked;
          if (_endTimeOfDay.hour < _startTimeOfDay.hour ||
              (_endTimeOfDay.hour == _startTimeOfDay.hour && _endTimeOfDay.minute < _startTimeOfDay.minute)) {
            _endTimeOfDay = TimeOfDay(hour: (_startTimeOfDay.hour + 1) % 24, minute: _startTimeOfDay.minute);
          }
        } else {
          _endTimeOfDay = picked;
        }
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final tasksProvider = Provider.of<TasksProvider>(context, listen: false);
      
      DateTime dueDate;
      DateTime? startTime;

      if (_hasTimeRange) {
        startTime = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _startTimeOfDay.hour,
          _startTimeOfDay.minute,
        );
        dueDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _endTimeOfDay.hour,
          _endTimeOfDay.minute,
        );
      } else {
        startTime = null;
        dueDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
        );
      }

      final updatedTask = widget.task.copyWith(
        title: _titleController.text.trim(),
        categoryId: _selectedCategoryId,
        dueDate: dueDate,
        startTime: startTime,
        priority: _selectedPriority,
        has30MinReminder: _hasTimeRange ? _has30MinReminder : false,
        hasStartReminder: _hasTimeRange ? _hasStartReminder : false,
      );

      tasksProvider.updateTask(updatedTask);
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Task updated successfully!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);
    final categoriesProvider = Provider.of<CategoriesProvider>(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: mediaQuery.viewInsets.bottom,
        left: 20.0,
        right: 20.0,
        top: 20.0,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Indicator
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Edit Task',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Title input
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'What needs to be done?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit_calendar_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a task title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector (Choice Chips list)
              Text(
                'Category',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: categoriesProvider.categories.map((category) {
                    final bool isSelected = _selectedCategoryId == category.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        avatar: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Color(category.colorValue),
                            shape: BoxShape.circle,
                          ),
                        ),
                        label: Text(category.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedCategoryId = category.id;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Priority Selector
              Text(
                'Priority',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: TaskPriority.values.map((priority) {
                  final bool isSelected = _selectedPriority == priority;
                  
                  Color getPriorityColor() {
                    switch (priority) {
                      case TaskPriority.high:
                        return Colors.red;
                      case TaskPriority.medium:
                        return Colors.orange;
                      case TaskPriority.low:
                        return Colors.blue;
                    }
                  }

                  return ChoiceChip(
                    label: Text(
                      priority.name[0].toUpperCase() + priority.name.substring(1),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      }
                    },
                    selectedColor: getPriorityColor().withValues(alpha: 0.2),
                    checkmarkColor: getPriorityColor(),
                    labelStyle: TextStyle(
                      color: isSelected ? getPriorityColor() : theme.colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Due Date Selector
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined),
                title: const Text('Due Date'),
                subtitle: Text(
                  '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                trailing: TextButton(
                  onPressed: () => _selectDate(context),
                  child: const Text('Select Date'),
                ),
              ),

              // Time Range Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: const Icon(Icons.access_time_outlined),
                title: const Text('Set Start & End Time'),
                subtitle: const Text('Specify hours for this task'),
                value: _hasTimeRange,
                onChanged: (val) {
                  setState(() {
                    _hasTimeRange = val;
                  });
                },
              ),

              if (_hasTimeRange) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context, true),
                        icon: const Icon(Icons.play_circle_outline, size: 18),
                        label: Text('Start: ${_startTimeOfDay.format(context)}'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context, false),
                        icon: const Icon(Icons.stop_circle_outlined, size: 18),
                        label: Text('End: ${_endTimeOfDay.format(context)}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Reminder Checkboxes
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Remind 30 mins before start'),
                  secondary: const Icon(Icons.notifications_active_outlined, size: 20),
                  value: _has30MinReminder,
                  onChanged: (val) {
                    setState(() {
                      _has30MinReminder = val ?? true;
                    });
                  },
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('Remind exactly when task starts'),
                  secondary: const Icon(Icons.alarm, size: 20),
                  value: _hasStartReminder,
                  onChanged: (val) {
                    setState(() {
                      _hasStartReminder = val ?? true;
                    });
                  },
                ),
              ],
              const SizedBox(height: 24),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Save Task'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

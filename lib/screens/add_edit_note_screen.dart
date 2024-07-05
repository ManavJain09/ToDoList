// lib/screens/add_edit_task_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/blocs/task_bloc.dart';
import 'package:todo_list/models/note_view_model.dart';
import 'package:todo_list/services/notification_service.dart';
import 'package:intl/intl.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  AddEditTaskScreen({Key? key, this.task}) : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _dueDate;
  late int _priority;
  bool _hasReminder = false;
  late DateTime? _reminderDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController = TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate ?? DateTime.now();
    _priority = widget.task?.priority ?? 1;
    _hasReminder = widget.task?.hasReminder ?? false;
    _reminderDate = widget.task?.reminderDate;

    // Initialize reminder date if task has reminder but no specific date set
    if (_hasReminder && _reminderDate == null) {
      _reminderDate = _dueDate.subtract(Duration(days: 1));
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_dueDate),
      );

      if (pickedTime != null) {
        setState(() {
          _dueDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectReminder(BuildContext context) async {
    final DateTime? pickedReminderDate = await showDatePicker(
      context: context,
      initialDate: _reminderDate ?? _dueDate,
      firstDate: DateTime.now(),
      lastDate: _dueDate,
    );

    if (pickedReminderDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_reminderDate ?? _dueDate),
      );

      if (pickedTime != null) {
        setState(() {
          _reminderDate = DateTime(
            pickedReminderDate.year,
            pickedReminderDate.month,
            pickedReminderDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (widget.task != null)
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                BlocProvider.of<TaskBloc>(context).add(DeleteTask(widget.task!.id));
                Navigator.of(context).pop();
              },
            ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Title',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Due Date: ${DateFormat('yyyy-MM-dd hh:mm a').format(_dueDate)}',
                  ),
                ),
                TextButton(
                  onPressed: () => _selectDate(context),
                  child: Text('Select Date'),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            Row(
              children: [
                Checkbox(
                  value: _hasReminder,
                  onChanged: (value) {
                    setState(() {
                      _hasReminder = value!;
                      if (!_hasReminder) {
                        _reminderDate = null;
                      } else {
                        _reminderDate ??= _dueDate.subtract(Duration(days: 1));
                      }
                    });
                  },
                ),
                Text('Set Reminder'),
                SizedBox(width: 16.0),
                Expanded(
                  child: Text(
                    _hasReminder
                        ? 'Reminder: ${DateFormat('yyyy-MM-dd hh:mm a').format(_reminderDate!)}'
                        : 'No Reminder Set',
                  ),
                ),
                TextButton(
                  onPressed: _hasReminder ? () => _selectReminder(context) : null,
                  child: Text('Select Reminder'),
                ),
              ],
            ),
            SizedBox(height: 12.0),
            DropdownButtonFormField<int>(
              value: _priority,
              onChanged: (value) {
                setState(() {
                  _priority = value!;
                });
              },
              items: const [
                DropdownMenuItem<int>(
                  value: 1,
                  child: Text('High Priority'),
                ),
                DropdownMenuItem<int>(
                  value: 2,
                  child: Text('Medium Priority'),
                ),
                DropdownMenuItem<int>(
                  value: 3,
                  child: Text('Low Priority'),
                ),
              ],
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                final task = Task(
                  id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _titleController.text,
                  description: _descriptionController.text,
                  dueDate: _dueDate,
                  priority: _priority,
                  hasReminder: _hasReminder,
                  reminderDate: _reminderDate,
                );

                if (widget.task == null) {
                  BlocProvider.of<TaskBloc>(context).add(AddTask(task));
                } else {
                  BlocProvider.of<TaskBloc>(context).add(UpdateTask(task));
                }

                if (_hasReminder && _reminderDate != null) {
                  NotificationService().scheduleNotification(
                    task.id as int,
                    task.title,
                    task.description,
                    _reminderDate!,
                  );
                }

                Navigator.of(context).pop();
              },
              child: Text(widget.task == null ? 'Add Task' : 'Update Task'),
            ),
          ],
        ),
      ),
    );
  }
}

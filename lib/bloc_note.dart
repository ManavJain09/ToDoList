import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/repository_note.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'note_view_model.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

// Events
abstract class TaskEvent {}

class LoadTasks extends TaskEvent {}

class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
}

class UpdateTask extends TaskEvent {
  final Task task;
  UpdateTask(this.task);
}

class DeleteTask extends TaskEvent {
  final String taskId;
  DeleteTask(this.taskId);
}

// States
abstract class TaskState {}

class TaskInitial extends TaskState {}

class TaskLoadInProgress extends TaskState {}

class TaskLoadSuccess extends TaskState {
  final List<Task> tasks;
  TaskLoadSuccess(this.tasks);
}

class TaskLoadFailure extends TaskState {}

// Bloc
class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;

  TaskBloc(this.repository) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
  }

  Future<void> _scheduleNotification(Task task) async {
    tz.initializeTimeZones(); // Ensure this is called to initialize timezones

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    if (task.hasReminder && task.reminderDate != null) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Reminder: ${task.title}',
        'Your task "${task.title}" is due soon.',
        tz.TZDateTime.from(task.reminderDate!, tz.local),
        platformChannelSpecifics,
        payload: task.id,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }

    if (task.priority == 1) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        1,
        'High Priority: ${task.title}',
        'Your high priority task "${task.title}" is due soon.',
        tz.TZDateTime.from(task.dueDate.subtract(Duration(minutes: 15)), tz.local),
        platformChannelSpecifics,
        payload: task.id,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void _onLoadTasks(LoadTasks event, Emitter<TaskState> emit) async {
    emit(TaskLoadInProgress());
    try {
      final tasks = await repository.loadTasks();
      emit(TaskLoadSuccess(tasks));
    } catch (_) {
      emit(TaskLoadFailure());
    }
  }

  void _onAddTask(AddTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = List<Task>.from((state as TaskLoadSuccess).tasks)..add(event.task);
      emit(TaskLoadSuccess(updatedTasks));
      await repository.saveTasks(updatedTasks);

      await _scheduleNotification(event.task);
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = (state as TaskLoadSuccess).tasks.map((task) {
        return task.id == event.task.id ? event.task : task;
      }).toList();
      emit(TaskLoadSuccess(updatedTasks));
      await repository.saveTasks(updatedTasks);

      await _scheduleNotification(event.task);
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = (state as TaskLoadSuccess).tasks.where((task) => task.id != event.taskId).toList();
      emit(TaskLoadSuccess(updatedTasks));
      await repository.saveTasks(updatedTasks);
    }
  }
  
}
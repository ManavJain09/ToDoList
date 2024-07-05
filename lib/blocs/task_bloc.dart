import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:todo_list/models/note_view_model.dart';
import 'package:todo_list/controller/repository_note.dart';
import 'package:todo_list/services/notification_service.dart';

part 'task_event.dart';
part 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final TaskRepository repository;
  final NotificationService notificationService;


  TaskBloc(this.repository, this.notificationService) : super(TaskInitial()) {
    on<LoadTasks>(_onLoadTasks);
    on<AddTask>(_onAddTask);
    on<UpdateTask>(_onUpdateTask);
    on<DeleteTask>(_onDeleteTask);
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
      await repository.addTask(event.task);

      if (event.task.hasReminder && event.task.reminderDate != null) {
        await notificationService.scheduleNotification(
          int.parse(event.task.id),
          'Task Reminder',
          event.task.title,
          event.task.reminderDate!,
        );
      }
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = (state as TaskLoadSuccess).tasks.map((task) {
        return task.id == event.task.id ? event.task : task;
      }).toList();
      emit(TaskLoadSuccess(updatedTasks));
      await repository.updateTask(event.task);

      if (event.task.hasReminder && event.task.reminderDate != null) {
        await notificationService.scheduleNotification(
          int.parse(event.task.id),
          'Task Reminder',
          event.task.title,
          event.task.reminderDate!,
        );
      }
    }
  }

  void _onDeleteTask(DeleteTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = (state as TaskLoadSuccess).tasks.where((task) => task.id != event.taskId).toList();
      emit(TaskLoadSuccess(updatedTasks));
      await repository.deleteTask(event.taskId);

    }
  }
}

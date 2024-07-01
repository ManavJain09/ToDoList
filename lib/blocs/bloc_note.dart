import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/controller/repository_note.dart';
import 'package:todo_list/models/note_view_model.dart';

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
    }
  }

  void _onUpdateTask(UpdateTask event, Emitter<TaskState> emit) async {
    if (state is TaskLoadSuccess) {
      final updatedTasks = (state as TaskLoadSuccess).tasks.map((task) {
        return task.id == event.task.id ? event.task : task;
      }).toList();
      emit(TaskLoadSuccess(updatedTasks));
      await repository.saveTasks(updatedTasks);
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
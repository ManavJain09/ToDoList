// lib/repositories/task_repository.dart

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'note_view_model.dart';



class TaskRepository {
  Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tasksJson = tasks.map((task) => json.encode(task.toJson())).toList();
    await prefs.setStringList('tasks', tasksJson);
  }

  Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? tasksJson = prefs.getStringList('tasks');
    if (tasksJson == null) return [];

    List<Task> tasks = tasksJson.map((taskJson) => Task.fromJson(json.decode(taskJson))).toList();
    tasks.sort((a, b) => a.priority.compareTo(b.priority)); // Sort tasks by priority
    return tasks;
  }
}
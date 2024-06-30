import 'package:flutter/material.dart';

import 'add_edit_note_screen.dart';
import 'note_view_model.dart';


class TaskSearchDelegate extends SearchDelegate<String> {
  final List<Task> tasks;

  TaskSearchDelegate(this.tasks);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final filteredTasks = tasks.where((task) =>
    task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.description.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(task: task),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestionList = tasks.where((task) =>
    task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.description.toLowerCase().contains(query.toLowerCase())).toList();

    return ListView.builder(
      itemCount: suggestionList.length,
      itemBuilder: (context, index) {
        final task = suggestionList[index];
        return ListTile(
          title: Text(task.title),
          subtitle: Text(task.description),
          onTap: () {
            query = task.title; // Set query to selected task title
            showResults(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddEditTaskScreen(task: task),
              ),
            );
          },
        );
      },
    );
  }
}
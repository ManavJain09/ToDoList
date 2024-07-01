import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todo_list/screens/taskSearchPage.dart';

import 'add_edit_note_screen.dart';
import 'package:todo_list/blocs/bloc_note.dart';
import 'package:todo_list/models/note_view_model.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ToDo List'),
        actions: [
          IconButton(
            icon: Icon(Icons.sort),
            tooltip: 'Sort Tasks',
            onPressed: () {
              BlocProvider.of<TaskBloc>(context).add(LoadTasks());
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search Tasks',
            onPressed: () {
              final state = BlocProvider.of<TaskBloc>(context).state;
              if (state is TaskLoadSuccess) {
                showSearch(
                  context: context,
                  delegate: TaskSearchDelegate(state.tasks),
                );
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TaskBloc, TaskState>(
        builder: (context, state) {
          if (state is TaskLoadInProgress) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is TaskLoadSuccess) {
            List<Task> tasks = state.tasks;
            tasks.sort((a, b) => a.priority.compareTo(b.priority));

            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return Dismissible(
                  key: Key(task.id.toString()),
                  background: Container(
                    color: Colors.red,
                    child: Icon(Icons.delete, color: Colors.white),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20.0),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    BlocProvider.of<TaskBloc>(context).add(DeleteTask(task.id));
                  },
                  child: ListTile(
                    tileColor: _getPriorityColor(task.priority),
                    title: Text(task.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        Text('Priority: ${_getPriorityText(task.priority)}'),
                      ],
                    ),
                    onTap: () {
                      _navigateToAddEditTaskScreen(context, task);
                    },
                  ),
                );
              },
            );
          } else {
            return Center(
              child: Text('Failed to load tasks'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _navigateToAddEditTaskScreen(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red[100]!;
      case 2:
        return Colors.yellow[100]!;
      case 3:
        return Colors.green[100]!;
      default:
        return Colors.white;
    }
  }

  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return 'High Priority';
      case 2:
        return 'Medium Priority';
      case 3:
        return 'Low Priority';
      default:
        return 'Unknown Priority';
    }
  }

  void _navigateToAddEditTaskScreen(BuildContext context, [Task? task]) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditTaskScreen(task: task),
      ),
    );
  }
}

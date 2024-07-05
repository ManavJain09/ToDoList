import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_list/controller/repository_note.dart';
import 'package:todo_list/services/notification_service.dart';
import 'package:todo_list/blocs/task_bloc.dart';
import 'package:todo_list/screens/note_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final taskRepository = TaskRepository();
  final notificationService = NotificationService();
  await _requestNotificationPermission();
  await notificationService.init();

  runApp(MyApp(taskRepository: taskRepository, notificationService: notificationService));
}
Future<void> _requestNotificationPermission() async {
  final status = await Permission.notification.status;
  if (!status.isGranted) {
    await Permission.notification.request();
  }
}
class MyApp extends StatelessWidget {
  final TaskRepository taskRepository;
  final NotificationService notificationService;

  MyApp({required this.taskRepository, required this.notificationService});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TaskBloc(taskRepository, notificationService)..add(LoadTasks()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ToDo List',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: TaskScreen(),
      ),
    );
  }
}

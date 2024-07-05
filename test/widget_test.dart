import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_list/main.dart';
import 'package:todo_list/controller/repository_note.dart';
import 'package:todo_list/services/notification_service.dart'; // Import your TaskRepository class

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create a TaskRepository instance for testing
    TaskRepository taskRepository = TaskRepository();
    NotificationService notificationService = NotificationService();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(taskRepository: taskRepository, notificationService: notificationService));

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}

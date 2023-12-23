import 'package:flutter/material.dart';
import 'calendar_page.dart';
import 'todo_item.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final todos = await fetchTodos();
  runApp(MyApp(todos: todos));
}

class MyApp extends StatelessWidget {
  final Map<DateTime, List<TodoItem>> todos;

  const MyApp({super.key, required this.todos});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter ToDo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CalendarPage(todos: todos),
    );
  }
}

Future<Map<DateTime, List<TodoItem>>> fetchTodos() async {
  final response = await http.get(Uri.parse('http://localhost:3000/todos'));

  if (response.statusCode == 200) {
    List<dynamic> todosJson = jsonDecode(response.body);
    Map<DateTime, List<TodoItem>> todos = {};
    for (var json in todosJson) {
      var todo = TodoItem.fromJson(json);
      if (!todos.containsKey(todo.dateTime)) {
        todos[todo.dateTime] = [];
      }
      todos[todo.dateTime]!.add(todo);
    }
    return todos;
  } else {
    throw Exception('Failed to load todos');
  }
}

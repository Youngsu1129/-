// todo_list_page.dart
import 'package:flutter/material.dart';
import 'todo_item.dart';

class TodoListPage extends StatelessWidget {
  final Map<DateTime, List<TodoItem>> todos;
  final Function(Map<DateTime, List<TodoItem>>) onUpdateTodos;

  const TodoListPage({super.key, required this.todos, required this.onUpdateTodos});

  @override
  Widget build(BuildContext context) {
    List<TodoItem> allTodos = todos.values.expand((x) => x).toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('ToDo List'),
      ),
      body: ListView.builder(
        itemCount: allTodos.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(allTodos[index].description),
            subtitle: Text(allTodos[index].dateTime.toString()),
          );
        },
      ),
      // You can add a FloatingActionButton or any other UI elements for further interactions
    );
  }
}

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'todo_item.dart';
import 'todo_list_page.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CalendarPage extends StatefulWidget {
  final Map<DateTime, List<TodoItem>> todos;

  const CalendarPage({super.key, required this.todos});

  @override
  CalendarPageState createState() => CalendarPageState();
}

class CalendarPageState extends State<CalendarPage> {
  DateTime selectedDay = DateTime.now();
  final TextEditingController _descriptionController = TextEditingController();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar ToDo'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => _navigateToTodoListPage(context, widget.todos),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          TableCalendar(
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: selectedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                this.selectedDay = selectedDay;
              });
            },
          ),
          const SizedBox(height: 16),
          Text(
            'Selected Day: ${DateFormat('yyyy-MM-dd').format(selectedDay)}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          ElevatedButton(
            onPressed: () => _addOrEditTodo(),
            child: const Text('Add Todo'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.todos[selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(widget.todos[selectedDay]![index].description),
                  subtitle: Text(widget.todos[selectedDay]![index].dateTime.toString()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

void _addOrEditTodo() async {
  final BuildContext dialogContext = context;

  await showDialog(
    context: dialogContext,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Add Todo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Todo Description'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _selectDateTime(),
              child: const Text('Select Date and Time'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              DateTime newDateTime = DateTime(
                selectedDay.year,
                selectedDay.month,
                selectedDay.day,
                _selectedTime.hour,
                _selectedTime.minute,
              );

              TodoItem newTodo = TodoItem(
                dateTime: newDateTime,
                description: _descriptionController.text,
              );

              Navigator.pop(context); // ダイアログを閉じる
              _descriptionController.clear();

              // 非同期処理の後でウィジェットが存在するかチェック
              if (!mounted) return;

              await saveTodoToServer(newTodo);
              await _refreshTodos();
            },
            child: const Text('Add'),
          ),
        ],
      );
    },
  );
}


  Future<void> saveTodoToServer(TodoItem todo) async {
    await http.post(
      Uri.parse('http://localhost:3000/todos'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(todo.toJson()),
    );
  }

  void _selectDateTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
    }
  }

  Future<void> _refreshTodos() async {
  final updatedTodos = await fetchTodos();
  setState(() {
    // 新しい Map を作成し、CalendarPage に渡します
    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (context) => CalendarPage(todos: updatedTodos),
    ));
  });
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

  void _navigateToTodoListPage(BuildContext context, Map<DateTime, List<TodoItem>> todos) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TodoListPage(
          todos: todos,
          onUpdateTodos: (updatedTodos) {
            // Handle updates if needed
          },
        ),
      ),
    );
  }
}

// todo_item.dart

class TodoItem {
  DateTime dateTime; // Combine date and time into a single DateTime object
  String description;

  TodoItem({required this.dateTime, required this.description});

  factory TodoItem.fromJson(Map<String, dynamic> json) => TodoItem(
        dateTime: DateTime.parse(json["dateTime"]),
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "dateTime": dateTime.toIso8601String(),
        "description": description,
      };
}

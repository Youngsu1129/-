import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:project/main.dart';
import 'package:table_calendar/table_calendar.dart'; // あなたのアプリ名に置き換えてください

void main() {
  testWidgets('App should start and display calendar and ToDo list', (WidgetTester tester) async {
    // アプリをビルドします。
    await tester.pumpWidget(const MyApp(todos: {},));

    // カレンダーウィジェットが存在することを確認します。
    expect(find.byType(TableCalendar), findsOneWidget);

    // ToDoリストアイテムが表示されているか確認します。
    // この部分は、ToDoリストの初期状態に応じて変更する必要があります。
    expect(find.byType(ListTile), findsNothing);

    // FAB（Floating Action Button）が存在することを確認します。
    expect(find.byIcon(Icons.add), findsOneWidget);
  });
}

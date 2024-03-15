import 'package:flutter/material.dart';
import 'package:riverpod_todo/widget/todo_input_field.dart';
import 'package:riverpod_todo/widget/todo_list.dart';

class TodoListView extends StatelessWidget {
  const TodoListView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        TodoInputField(),
        Expanded(child: TodoList()),
      ],
    );
  }
}

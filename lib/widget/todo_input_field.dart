import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo/controller/todo_provider.dart';
import 'package:riverpod_todo/model/todo.dart';

class TodoInputField extends ConsumerWidget {
  const TodoInputField({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoContentTextController = TextEditingController();
    final todoContentTextFocusNode = FocusNode();

    void onPressedAddButton() {
      final title = todoContentTextController.text;
      todoContentTextController.clear();
      final docId = FirebaseFirestore.instance.collection('todo').doc().id;

      final todo = Todo(
        todoId: docId,
        title: title,
        createdAt: DateTime.now(),
      );

      addTodoToFirestore(todo);
      FocusScope.of(context).requestFocus(todoContentTextFocusNode);
    }

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: todoContentTextController,
              focusNode: todoContentTextFocusNode,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onPressedAddButton,
          ),
        ],
      ),
    );
  }
}

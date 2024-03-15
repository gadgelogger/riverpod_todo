import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_todo/controller/todo_provider.dart';
import 'package:riverpod_todo/model/todo.dart';

class TodoList extends StatelessWidget {
  const TodoList({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('todos')
          .orderBy('createdAt')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        final todos = snapshot.data!.docs.map((DocumentSnapshot document) {
          final data = document.data()! as Map<String, dynamic>;
          return Todo.fromJson(data..['todoId'] = document.id);
        }).toList();

        return ListView.builder(
          itemCount: todos.length,
          itemBuilder: (context, index) {
            final todo = todos[index];
            final formattedDate =
                DateFormat('yyyy年MM月dd日 HH:mm').format(todo.createdAt);
            return Dismissible(
              key: Key(todo.todoId),
              background: Container(color: Colors.red),
              onDismissed: (direction) {
                deleteTodoFromFirestore(todo.todoId);
              },
              child: ListTile(
                title: Text(todo.title),
                subtitle: Text(formattedDate),
                trailing: Checkbox(
                  value: todo.isCompleted,
                  onChanged: (bool? newValue) {
                    toggleTodoCompleted(todo.todoId, todo.isCompleted);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}

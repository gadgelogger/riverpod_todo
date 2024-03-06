import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
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

class TodoListPage extends ConsumerWidget {
  const TodoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Todo')),
      body: const TodoListView(),
    );
  }
}

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

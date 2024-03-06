import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_todo/controller/todo_provider.dart';
import 'package:riverpod_todo/model/todo.dart';

class TodoListPage extends ConsumerWidget {
  final todoContentTextController = TextEditingController();
  final todoContentTextFocusNode = FocusNode();
  TodoListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todoList = ref.watch(todoListProvider);
    final todoListNotifier = ref.read(todoListProvider.notifier);

    // 追加ボタン押下
    void onPressedAddButton() {
      final title = todoContentTextController.text;
      todoContentTextController.clear();
      final docId = FirebaseFirestore.instance.collection('todo').doc().id;

      final todo = Todo(
        todoId: docId,
        title: title,
        createdAt: DateTime.now(),
      );

      // Firestoreに追加
      addTodoToFirestore(todo);
      FocusScope.of(context).requestFocus(todoContentTextFocusNode);
    }

    void onPressedDeleteButton(int index) {
      todoListNotifier.removeTodo(todoList[index].todoId);
    }

    void onPressedToggleButton(int index) {
      todoListNotifier.toggleCompleted(todoList[index].todoId);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: todoContentTextController,
                    focusNode: todoContentTextFocusNode,
                  ),
                ),
                ElevatedButton(
                  onPressed: onPressedAddButton,
                  child: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream:
                    FirebaseFirestore.instance.collection('todos').snapshots(),
                builder: (
                  BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot,
                ) {
                  if (snapshot.hasError) {
                    return const Text('Error');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  // FirestoreのドキュメントからTodoリストを作成
                  final todos =
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                    final data = document.data()! as Map<String, dynamic>;
                    return Todo.fromJson(
                      data,
                    ); // `Todo.fromJson`メソッドを適切に実装する必要があります
                  }).toList();

                  return ListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      final todo = todos[index];
                      final formattedDate = DateFormat('yyyy年MM月dd日 HH:mm')
                          .format(todos[index].createdAt);
                      return ListTile(
                        title: Text(todo.title),
                        subtitle: Text(formattedDate),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_todo/model/todo.dart';

final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(
  TodoListNotifier.new,
);

Future<void> addTodoToFirestore(Todo todo) async {
  final collection = FirebaseFirestore.instance.collection('todos');
  await collection.doc(todo.todoId).set(todo.toJson());
}

class TodoListNotifier extends Notifier<List<Todo>> {
  void addTodo(Todo todo) {
    state = [...state, todo];
  }

  @override
  List<Todo> build() {
    return [];
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.todoId != id).toList();
  }

  void toggleCompleted(String id) {
    state = state
        .map(
          (todo) => todo.todoId == id
              ? todo.copyWith(isCompleted: !todo.isCompleted)
              : todo,
        )
        .toList();
  }
}

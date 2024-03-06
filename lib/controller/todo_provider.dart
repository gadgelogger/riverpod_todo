import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_todo/model/todo.dart';

Future<void> addTodoToFirestore(Todo todo) async {
  final collection = FirebaseFirestore.instance.collection('todos');
  await collection.doc(todo.todoId).set(todo.toJson());
}

Future<void> deleteTodoFromFirestore(String todoId) async {
  await FirebaseFirestore.instance.collection('todos').doc(todoId).delete();
}

Future<void> toggleTodoCompleted(String docId, bool isCompleted) async {
  final document = FirebaseFirestore.instance.collection('todos').doc(docId);
  await document.update({'isCompleted': !isCompleted});
}
//StateNotifierクラス要らなくなる説
// class TodoListNotifier extends Notifier<List<Todo>> {
//   final todoListProvider = NotifierProvider<TodoListNotifier, List<Todo>>(
//     TodoListNotifier.new,
//   );
//   void add`Todo`(`Todo` `todo`) {
//     state = [...state, `todo`];
//   }

//   @override
//   List<Todo> build() {
//     return [];
//   }

//   void removeTodo(String id) {
//     state = state.where((`todo`) => `todo`.`todo`Id != id).toList();
//   }

//   void toggleCompleted(String id) {
//     state = state
//         .map(
//           (`todo`) => `todo`.`todo`Id == id
//               ? `todo`.copyWith(isCompleted: !`todo`.isCompleted)
//               : `todo`,
//         )
//         .toList();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore firestore;

  TaskRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> createTask({
    required String projectId,
    required TaskModel task,
  }) async {
    await firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .add(task.toJson());
  }

  Stream<List<TaskModel>> getTasksByStatus(String projectId, String status) {
    return firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .where('status', isEqualTo: status)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TaskModel.fromJson(doc.data()))
              .toList(),
        );
  }
}

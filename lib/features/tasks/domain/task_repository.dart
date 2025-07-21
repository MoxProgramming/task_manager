import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_manager/core/constants/priority.dart';
import 'package:task_manager/core/constants/task_status.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';

class TaskRepository {
  final FirebaseFirestore firestore;

  TaskRepository({FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<void> createTask({
    required String projectId,
    required String title,
    required String description,
    required Priority priority,
  }) async {
    final taskRef = firestore
        .collection('projects')
        .doc(projectId)
        .collection('tasks')
        .doc();
    final task = TaskModel(
      uid: taskRef.id,
      postedBy: uid,
      title: title,
      description: description,
      priority: priority,
      dateCreated: DateTime.now(),
      status: TaskStatus.open,
    );
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

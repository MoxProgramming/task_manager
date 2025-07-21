import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/core/constants/roles.dart';
import 'package:task_manager/core/constants/task_status.dart';
import 'package:task_manager/features/projects/data/models/project_model.dart';
import 'package:task_manager/features/projects/data/models/project_member_model.dart';
import 'package:task_manager/features/projects/data/models/user_project_model.dart';

class ProjectsRepository {
  final FirebaseFirestore _firestore;

  ProjectsRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Future<String?> createProject(String projectName) async {
    try {
      final now = DateTime.now();

      final projectRef = _firestore.collection('projects').doc();

      final project = ProjectModel(
        uid: projectRef.id,
        projectName: projectName,
        createdBy: uid,
        dateCreated: now,
      );

      final batch = _firestore.batch();
      batch.set(projectRef, project.toJson());

      final memberData = ProjectMemberModel(
        uid: uid,
        role: Roles.owner,
        dateJoined: now,
        taskStatusFilter: TaskStatus.values,
      );

      batch.set(projectRef.collection('members').doc(uid), memberData.toJson());

      final userProjectRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('projects')
          .doc(projectRef.id);

      final userData = UserProjectModel(
        uid: projectRef.id,
        role: Roles.owner,
        dateJoined: now,
        projectName: projectName,
      );

      batch.set(userProjectRef, userData.toJson());

      await batch.commit();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_project_id', projectRef.id);
      return projectRef.id;
    } catch (e) {
      return null;
    }
  }

  Future<void> addMemberToProject({
    required String projectId,
    required String newUid,
    required String projectName,
  }) async {
    final now = DateTime.now();

    final projectRef = _firestore.collection('projects').doc(projectId);

    final batch = _firestore.batch();

    final memberData = ProjectMemberModel(
      uid: newUid,
      role: Roles.user,
      dateJoined: now,
      taskStatusFilter: TaskStatus.values,
    );

    batch.set(
      projectRef.collection('members').doc(newUid),
      memberData.toJson(),
    );

    final userProjectData = UserProjectModel(
      uid: projectId,
      role: Roles.user,
      dateJoined: now,
      projectName: projectName,
    );

    batch.set(
      _firestore
          .collection('users')
          .doc(newUid)
          .collection('projects')
          .doc(projectId),
      userProjectData.toJson(),
    );

    await batch.commit();
  }

  Future<UserProjectModel?> getProjectById(String uid) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('projects')
          .where('uid', isEqualTo: uid)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return null;
      }

      final data = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return UserProjectModel.fromJson(data);
    } catch (e) {
      throw ProjectsRepositoryException(
        'Failed to fetch project by ID: ${e.toString()}',
      );
    }
  }

  // TODO: one is future and one stream, check which you need
  Future<List<UserProjectModel>> getProjectsByUser(String userId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('users/$userId/projects')
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return UserProjectModel.fromJson(data);
      }).toList();
    } catch (e) {
      throw ProjectsRepositoryException(
        'Failed to fetch projects: ${e.toString()}',
      );
    }
  }

  Stream<List<UserProjectModel>> getUserProjects(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('projects')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            return UserProjectModel.fromJson(data);
          }).toList();
        });
  }

  Future<void> updateProject(String docId, UserProjectModel project) async {
    await _firestore.collection('projects').doc(docId).update(project.toJson());
  }

  Future<void> deleteProject(String docId) async {
    await _firestore.collection('projects').doc(docId).delete();
  }

  // TODO: check these 2 calls
  Future<void> saveSelectedProjectId(String projectId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_project_id', projectId);
  }

  Future<String?> loadSelectedProjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selected_project_id');
  }

  // final members = await FirebaseFirestore.instance.collection('projects').doc(projectId).collection('members').orderBy('joinedAt').limit(50).get();

  // final snap = await FirebaseFirestore.instance.collectionGroup('projects').where('uid', isEqualTo: uid).get();
}

class ProjectsRepositoryException implements Exception {
  final String message;
  ProjectsRepositoryException(this.message);

  @override
  String toString() => 'ProjectRepositoryException: $message';
}

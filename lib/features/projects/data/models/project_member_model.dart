import 'package:task_manager/core/constants/roles.dart';
import 'package:task_manager/core/constants/task_status.dart';

// project -> members
class ProjectMemberModel {
  String uid;
  Roles role;
  DateTime dateJoined;
  List<TaskStatus> taskStatusFilter;

  ProjectMemberModel({
    required this.uid,
    required this.role,
    required this.dateJoined,
    required this.taskStatusFilter,
  });

  factory ProjectMemberModel.fromJson(Map<String, dynamic> json) {
    return ProjectMemberModel(
      uid: json['uid'],
      role: Roles.values.firstWhere((e) => e.name == json['role']),
      dateJoined: json['dateJoined'].toDate(),
      taskStatusFilter: (json['taskStatusFilter'] as List<dynamic>)
          .map((e) => TaskStatus.values.firstWhere((ts) => ts.name == e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role.name,
      'dateJoined': dateJoined,
      'taskStatusFilter': taskStatusFilter.map((e) => e.name).toList(),
    };
  }
}

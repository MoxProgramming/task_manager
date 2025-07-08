import 'package:task_manager/core/constants/roles.dart';

// user -> projects
class UserProjectModel {
  String uid; // project id from projects -> uid
  Roles role;
  DateTime dateJoined;
  String projectName;

  UserProjectModel({
    required this.uid,
    required this.role,
    required this.dateJoined,
    required this.projectName,
  });

  factory UserProjectModel.fromJson(Map<String, dynamic> json) {
    return UserProjectModel(
      uid: json['uid'],
      role: Roles.values.firstWhere((e) => e.name == json['role']),
      dateJoined: json['dateJoined'].toDate(),
      projectName: json['projectName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'role': role.name,
      'dateJoined': dateJoined,
      'projectName': projectName,
    };
  }
}

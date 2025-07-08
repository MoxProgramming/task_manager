class ProjectModel {
  final String uid;
  final String projectName;
  final String createdBy;
  final DateTime dateCreated;

  ProjectModel({
    required this.uid,
    required this.projectName,
    required this.createdBy,
    required this.dateCreated,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      uid: json['uid'],
      projectName: json['projectName'],
      createdBy: json['createdBy'],
      dateCreated: json['dateCreated'].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'projectName': projectName,
      'createdBy': createdBy,
      'dateCreated': dateCreated,
    };
  }
}

import 'package:task_manager/core/constants/priority.dart';
import 'package:task_manager/core/constants/task_status.dart';

class TaskModel {
  final String postedBy;
  final String title;
  final String? description;
  final Priority priority;
  final DateTime dateCreated;
  final TaskStatus status;
  final String? assignedTo;

  TaskModel({
    required this.postedBy,
    required this.title,
    this.description,
    required this.priority,
    required this.dateCreated,
    required this.status,
    this.assignedTo,
  });

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      postedBy: json['postedBy'],
      title: json['title'],
      description: json['description'],
      priority: Priority.values.firstWhere((e) => e.name == json['priority']),
      dateCreated: json['dateCreated'].toDate(),
      status: TaskStatus.values.firstWhere((e) => e.name == json['status']),
      assignedTo: json['assignedTo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postedBy': postedBy,
      'title': title,
      'description': description,
      'priority': priority.name,
      'dateCreated': dateCreated,
      'status': status.name,
      'assignedTo': assignedTo,
    };
  }
}

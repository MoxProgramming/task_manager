import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';

class TaskDetailRail extends StatelessWidget {
  const TaskDetailRail({super.key, required this.task, required this.onClose});

  final TaskModel task;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: Theme.of(context).dividerColor),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.close), onPressed: onClose),
                  const Text(
                    'Task Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
              Text(
                task.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(task.description ?? ''),
            ],
          ),
        ),
      ),
    ).animate().slide(
      begin: Offset(1, 0),
      end: Offset.zero,
      duration: 300.ms,
      curve: Curves.easeInOut,
    );
  }
}

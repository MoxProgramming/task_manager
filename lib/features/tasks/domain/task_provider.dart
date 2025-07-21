import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/projects/domain/projects_provider.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/domain/task_repository.dart';

final selectedProjectIdProvider = Provider<String?>((ref) {
  final selectedProject = ref.watch(selectedProjectProvider);
  return selectedProject?.uid;
});

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksProvider =
    StreamProvider.family<List<TaskModel>, ({String projectId, String status})>(
      (ref, params) {
        final repository = ref.watch(taskRepositoryProvider);
        return repository.getTasksByStatus(params.projectId, params.status);
      },
    );

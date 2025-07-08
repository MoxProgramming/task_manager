import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/domain/task_repository.dart';

final selectedProjectIdProvider = StateProvider<String?>((ref) => null);

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

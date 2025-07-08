import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/constants/roles.dart';
import 'package:task_manager/core/utils/shared_preferences_service.dart';
import 'package:task_manager/features/projects/data/models/user_project_model.dart';
import 'package:task_manager/features/projects/domain/projects_repository.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>((ref) {
  return ProjectsRepository();
});

final userProjectsStreamProvider =
    StreamProvider.family<List<UserProjectModel>, String>((ref, userId) {
      final repository = ref.read(projectsRepositoryProvider);
      return repository.getUserProjects(userId);
    });

class SelectedProjectNotifier extends StateNotifier<UserProjectModel?> {
  SelectedProjectNotifier() : super(null) {
    _loadSelectedProject();
  }

  Future<void> _loadSelectedProject() async {
    try {
      final hasProject = await SharedPreferencesService.hasSelectedProject();
      if (hasProject) {
        final projectName =
            await SharedPreferencesService.getSelectedProjectName();
        final projectUid =
            await SharedPreferencesService.getSelectedProjectUid();

        if (projectName != null && projectUid != null) {
          state = UserProjectModel(
            uid: projectUid,
            role: Roles.user,
            dateJoined: DateTime.now(),
            projectName: projectName,
          );
        }
      }
    } catch (e) {}
  }

  Future<void> selectProject(UserProjectModel? project) async {
    state = project;

    if (project != null) {
      await SharedPreferencesService.saveSelectedProject(
        project.projectName,
        project.uid,
      );
    } else {
      await SharedPreferencesService.clearSelectedProject();
    }
  }

  void updateSelectedProject(UserProjectModel project) {
    if (state != null &&
        state!.projectName == project.projectName &&
        state!.uid == project.uid) {
      state = project;
    }
  }
}

final selectedProjectProvider =
    StateNotifierProvider<SelectedProjectNotifier, UserProjectModel?>((ref) {
      return SelectedProjectNotifier();
    });

final projectNameProvider = Provider.family<List<String>, String>((
  ref,
  userId,
) {
  final projectsAsync = ref.watch(userProjectsStreamProvider(userId));

  return projectsAsync.when(
    data: (projects) => projects.map((p) => p.projectName).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});

final projectByNameProvider =
    Provider.family<UserProjectModel?, ({String userId, String projectName})>((
      ref,
      params,
    ) {
      final projectsAsync = ref.watch(
        userProjectsStreamProvider(params.userId),
      );

      return projectsAsync.when(
        data: (projects) {
          try {
            return projects.firstWhere(
              (p) => p.projectName == params.projectName,
            );
          } catch (e) {
            return null;
          }
        },
        loading: () => null,
        error: (_, __) => null,
      );
    });

// final selectedProjectProvider =
//     StateNotifierProvider<SelectedProjectNotifier, UserProjectModel?>((ref) {
//       final repo = ref.read(projectsRepositoryProvider);
//       return SelectedProjectNotifier(repo);
//     });

// class SelectedProjectNotifier extends StateNotifier<UserProjectModel?> {
//   final ProjectsRepository _repository;

//   SelectedProjectNotifier(this._repository) : super(null) {
//     _init();
//   }

//   Future<void> _init() async {
//     final projects = await _repository.getProjectsByUser();
//     final saveId = await _repository.loadSelectedProjectId();
//     final selected = projects.firstWhere((p) => p.uid == saveId);
//     state = selected;
//   }

//   void select(UserProjectModel project) {
//     _repository.saveSelectedProjectId(project.uid);
//     state = project;
//   }
// }

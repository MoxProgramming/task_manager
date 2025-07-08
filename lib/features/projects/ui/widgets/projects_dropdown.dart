import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/projects/data/models/user_project_model.dart';
import 'package:task_manager/features/projects/domain/projects_provider.dart';

class ProjectDropdownWidget extends ConsumerWidget {
  final String userId;
  final UserProjectModel? selectedProject;
  final String? hint;
  final ValueChanged<UserProjectModel?>? onChanged;

  const ProjectDropdownWidget({
    required this.userId,
    this.selectedProject,
    this.hint,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectsAsync = ref.watch(userProjectsStreamProvider(userId));

    return projectsAsync.when(
      data: (projects) {
        if (projects.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                Icon(Icons.folder_open, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'No projects available',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final selectedValue = projects.firstWhere(
          (p) => selectedProject?.uid == p.uid,
          orElse: () => projects.first,
        );

        return DropdownButtonFormField<UserProjectModel>(
          value:
              selectedProject != null &&
                  projects.any((p) => p.uid == selectedProject!.uid)
              ? selectedValue
              : null,
          hint: Text(hint ?? 'Select a project'),
          isExpanded: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            prefixIcon: const Icon(Icons.folder),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
          ),
          items: projects.map((project) {
            return DropdownMenuItem<UserProjectModel>(
              value: project,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    project.projectName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (UserProjectModel? project) {
            onChanged?.call(project);
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a project';
            }
            return null;
          },
        );
      },
      loading: () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 2),
            Text('Loading projects...'),
          ],
        ),
      ),
      error: (error, stackTrace) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.error, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Error loading projects: ${error.toString()}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.invalidate(userProjectsStreamProvider(userId));
              },
            ),
          ],
        ),
      ),
    );
  }
}

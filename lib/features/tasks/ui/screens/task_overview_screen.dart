import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/constants/task_status.dart';
import 'package:task_manager/features/auth/domain/auth_provider.dart';
import 'package:task_manager/features/projects/data/models/user_project_model.dart';
import 'package:task_manager/features/projects/ui/widgets/projects_dropdown.dart';
import 'package:task_manager/features/tasks/domain/task_provider.dart';
import 'package:task_manager/features/tasks/ui/screens/new_task_screen.dart';

class TaskOverviewScreen extends ConsumerStatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  ConsumerState<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends ConsumerState<TaskOverviewScreen> {
  UserProjectModel? selectedProject;

  @override
  Widget build(BuildContext context) {
    final statuses = TaskStatus.values;

    final user = ref.read(authStateChangesProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks Overview')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProjectDropdownWidget(
              userId: user!.uid, // Replace with actual user id
              selectedProject: selectedProject,
              onChanged: (project) {
                setState(() {
                  selectedProject = project;
                });
              },
            ),
          ),
          if (selectedProject == null)
            const Expanded(child: Center(child: Text('No project selected')))
          else
            Expanded(
              child: Row(
                children: statuses.map((status) {
                  final tasksAsync = ref.watch(
                    tasksProvider((
                      projectId: selectedProject!.uid,
                      status: status.name,
                    )),
                  );

                  return Expanded(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          color: Colors.grey[200],
                          child: Text(
                            status.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: tasksAsync.when(
                            data: (tasks) => ListView.builder(
                              itemCount: tasks.length,
                              itemBuilder: (context, index) {
                                final task = tasks[index];
                                return Card(
                                  margin: const EdgeInsets.all(8),
                                  child: ListTile(
                                    title: Text(task.title),
                                    subtitle: Text(task.description ?? ''),
                                  ),
                                );
                              },
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (e, _) => Center(child: Text('Error: $e')),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const NewTaskScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

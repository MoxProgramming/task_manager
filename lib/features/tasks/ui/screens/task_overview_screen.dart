import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/constants/task_status.dart';
import 'package:task_manager/features/auth/domain/auth_provider.dart';
import 'package:task_manager/features/projects/data/models/user_project_model.dart';
import 'package:task_manager/features/projects/domain/projects_provider.dart';
import 'package:task_manager/features/projects/ui/widgets/projects_dropdown.dart';
import 'package:task_manager/features/tasks/data/models/task_model.dart';
import 'package:task_manager/features/tasks/domain/task_provider.dart';
import 'package:task_manager/features/tasks/ui/screens/new_task_screen.dart';
import 'package:task_manager/features/tasks/ui/screens/task_detail_rail.dart';

class TaskOverviewScreen extends ConsumerStatefulWidget {
  const TaskOverviewScreen({super.key});

  @override
  ConsumerState<TaskOverviewScreen> createState() => _TaskOverviewScreenState();
}

class _TaskOverviewScreenState extends ConsumerState<TaskOverviewScreen>
    with SingleTickerProviderStateMixin {
  TaskModel? _selectedTask;
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _selectTask(TaskModel task) {
    setState(() {
      _selectedTask = task;
    });
    _animationController.forward();
  }

  void _closeTask() {
    _animationController.reverse().then((_) {
      setState(() {
        _selectedTask = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final statuses = TaskStatus.values;
    final user = ref.read(authStateChangesProvider).value;
    final selectedProject = ref.watch(selectedProjectProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Tasks Overview')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ProjectDropdownWidget(
              userId: user!.uid,
              selectedProject: selectedProject,
              onChanged: (project) {
                ref
                    .read(selectedProjectProvider.notifier)
                    .selectProject(project);
              },
            ),
          ),
          if (selectedProject == null)
            const Expanded(child: Center(child: Text('No project selected')))
          else
            Expanded(
              child: Row(
                children: [
                  // Task columns
                  Expanded(
                    flex: _selectedTask == null ? 1 : 1,
                    child: Row(
                      children: statuses.map((status) {
                        final tasksAsync = ref.watch(
                          tasksProvider((
                            projectId: selectedProject.uid,
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
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
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
                                          title: Material(
                                            type: MaterialType.transparency,
                                            child: Text(task.title),
                                          ),
                                          subtitle: Text(
                                            task.description ?? '',
                                          ),
                                          onTap: () => _selectTask(task),
                                        ),
                                      );
                                    },
                                  ),
                                  loading: () => const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                  error: (e, _) =>
                                      Center(child: Text('Error: $e')),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  // Task detail panel
                  if (_selectedTask != null)
                    Expanded(
                      flex: 1,
                      child: AnimatedBuilder(
                        animation: _slideAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(
                              _slideAnimation.value *
                                  MediaQuery.of(context).size.width,
                              0,
                            ),
                            child: TaskDetailRail(
                              task: _selectedTask!,
                              onClose: _closeTask,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: selectedProject != null
          ? FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NewTaskScreen()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

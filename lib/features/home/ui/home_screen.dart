import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/features/auth/domain/auth_provider.dart';
import 'package:task_manager/features/projects/ui/screens/new_project_screen.dart';
import 'package:task_manager/features/tasks/ui/screens/new_task_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModelAsync = ref.watch(userModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: userModelAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('No user data found.'));
          }
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Email: ${user.email}'),
                Text('Nickname: ${user.nickname}'),
                ElevatedButton(
                  child: Text('New Project'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NewProjectScreen(),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: Text('New Task'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const NewTaskScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

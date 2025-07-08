import 'package:flutter/material.dart';
import 'package:task_manager/features/auth/ui/screens/login_screen.dart';
import 'package:task_manager/features/auth/ui/screens/register_screen.dart';
import 'package:task_manager/features/projects/ui/screens/new_project_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/login': (_) => const LoginScreen(),
  '/register': (_) => const RegisterScreen(),
  '/new_project': (_) => const NewProjectScreen(),
};

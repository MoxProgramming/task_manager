import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/widgets/text_field.dart';
import 'package:task_manager/features/auth/domain/auth_provider.dart';
import 'package:task_manager/features/auth/ui/screens/register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final authRepo = ref.read(authRepositoryProvider);
    final error = await authRepo.signIn(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );
    if (mounted) {
      setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            AppTextField(
              controller: _emailController,
              label: 'Email',
              obscureText: false,
            ),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _signIn, child: Text('Login')),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Don\'t have an account? Register'),
            ),
          ],
        ),
      ),
    );
  }
}

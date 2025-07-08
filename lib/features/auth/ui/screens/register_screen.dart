import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:task_manager/core/widgets/text_field.dart';
import 'package:task_manager/features/auth/domain/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  String? _errorMessage;

  String _lastCheckedNickname = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_onNicknameChanged);
    _debounce?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  void _onNicknameChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _lastCheckedNickname = _nicknameController.text.trim();
      });
    });
  }

  Future<void> _register() async {
    final authRepo = ref.read(authRepositoryProvider);
    final error = await authRepo.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
      _nicknameController.text.trim(),
    );
    if (error == null) {
      if (mounted) Navigator.of(context).pop();
    } else {
      if (mounted) setState(() => _errorMessage = error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final nicknameAsync = ref.watch(
      nicknameCheckProvider(_lastCheckedNickname),
    );
    final isNicknameTaken = nicknameAsync.value ?? false;

    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            AppTextField(controller: _emailController, label: 'Email'),
            AppTextField(
              controller: _passwordController,
              label: 'Password',
              obscureText: true,
            ),
            AppTextField(controller: _nicknameController, label: 'Nickname'),
            if (isNicknameTaken)
              Text(
                'This nickname is already taken.',
                style: TextStyle(color: Colors.red),
              ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isNicknameTaken ? null : _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

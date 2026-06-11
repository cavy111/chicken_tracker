import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _displayNameCtrl = TextEditingController();
  bool _isRegister = false;
  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text;
    final displayName = _displayNameCtrl.text.trim();

    final authNotifier = ref.read(authProvider.notifier);
    if (_isRegister) {
      await authNotifier.register(
        email: email,
        password: password,
        displayName: displayName.isEmpty ? email.split('@')[0] : displayName,
      );
    } else {
      await authNotifier.login(email: email, password: password);
    }

    final authState = ref.read(authProvider);
    setState(() => _loading = false);

    if (authState.isAuthenticated) {
      if (!mounted) return;
      context.go('/batches');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication failed')),
      );
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _displayNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return Scaffold(
        appBar: AppBar(title: const Text('Authenticated')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Hello, ${authState.displayName ?? authState.email}'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                },
                child: const Text('Logout'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordCtrl,
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    if (_isRegister) ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _displayNameCtrl,
                        decoration:
                            const InputDecoration(labelText: 'Display Name'),
                      ),
                    ],
                    const SizedBox(height: 12),
                    _loading
                        ? const CircularProgressIndicator()
                        : Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _submit,
                                  child: Text(_isRegister ? 'Register' : 'Login'),
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        setState(() => _isRegister = !_isRegister);
                      },
                      child: Text(_isRegister
                          ? 'Have an account? Login'
                          : 'Create account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
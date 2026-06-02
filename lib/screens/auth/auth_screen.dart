import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _usernameCtl = TextEditingController();
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _usernameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return Column(
                children: [
                  const SizedBox(height: 40),
                  Text('thiraipedia',
                      style: TextStyle(
                          color: AppTheme.primaryColor,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Text('Premium Film Critique & Reviews',
                      style: TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 40),
                  Text(_isLogin ? 'Welcome Back' : 'Join ThiraiPedia',
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _usernameCtl,
                    decoration: const InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 16),
                  if (!_isLogin)
                    TextField(
                      controller: _emailCtl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email)),
                    ),
                  if (!_isLogin) const SizedBox(height: 16),
                  TextField(
                    controller: _passwordCtl,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.loading
                          ? null
                          : () => _handleAuth(auth),
                      child: auth.loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2))
                          : Text(_isLogin ? 'Sign In' : 'Create Account'),
                    ),
                  ),
                  if (auth.error != null) ...[
                    const SizedBox(height: 12),
                    Text(auth.error!,
                        style: const TextStyle(
                            color: AppTheme.primaryColor, fontSize: 13)),
                  ],
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() => _isLogin = !_isLogin);
                      auth.error;
                    },
                    child: Text(
                      _isLogin
                          ? "Don't have an account? Sign up"
                          : 'Already have an account? Sign in',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _handleAuth(AuthProvider auth) async {
    final username = _usernameCtl.text.trim();
    final password = _passwordCtl.text.trim();
    if (username.isEmpty || password.isEmpty) return;
    if (!_isLogin) {
      final email = _emailCtl.text.trim();
      if (email.isEmpty) return;
      final success = await auth.register(username, email, password);
      if (success && mounted) Navigator.pop(context);
    } else {
      final success = await auth.login(username, password);
      if (success && mounted) Navigator.pop(context);
    }
  }
}

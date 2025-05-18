import 'package:flutter/material.dart';
import '../main.dart';
import '../user_database.dart';
import 'signup_page.dart';

class LoginPage extends StatefulWidget {
  final void Function(String username) onLoginSuccess;
  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Login',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  onChanged: (val) => _username = val,
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? 'Enter username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  onChanged: (val) => _password = val,
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? 'Enter password' : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final success = await AuthService.login(
                        _username,
                        _password,
                      );
                      if (success) {
                        widget.onLoginSuccess(_username);
                      } else {
                        setState(() => _error = 'Invalid credentials');
                      }
                    }
                  },
                  child: const Text('Login'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder:
                            (_) => SignUpPage(
                              onSignUp: () => widget.onLoginSuccess(_username),
                            ),
                      ),
                    );
                  },
                  child: const Text('No account? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../main.dart';

class SignUpPage extends StatefulWidget {
  final VoidCallback onSignUp;
  const SignUpPage({super.key, required this.onSignUp});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
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
                  'Sign Up',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Name'),
                  onChanged: (val) => _name = val,
                  validator:
                      (val) =>
                          val == null || val.isEmpty ? 'Enter your name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (val) => _email = val,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'Enter your email';
                    final emailRegex = RegExp(
                      r'^[^@\s]+@[^@\s]+\.[^@\s]+\u0000?$',
                    );
                    if (!emailRegex.hasMatch(val)) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
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
                      final success = await AuthService.signUp(
                        _username,
                        _password,
                        name: _name,
                        email: _email,
                      );
                      if (success) {
                        widget.onSignUp();
                        Navigator.of(context).pop();
                      } else {
                        setState(() => _error = 'Account already exists');
                      }
                    }
                  },
                  child: const Text('Sign Up'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

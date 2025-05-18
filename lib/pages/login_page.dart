import 'package:flutter/material.dart';
import '../main.dart';
import '../user_database.dart';
import '../google_signin_service.dart';
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset('assets/logo.png', height: 64),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Login to your account',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Username',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (val) => _username = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Enter username'
                                  : null,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Colors.black),
                      ),
                      obscureText: true,
                      onChanged: (val) => _password = val,
                      validator:
                          (val) =>
                              val == null || val.isEmpty
                                  ? 'Enter password'
                                  : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
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
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      icon: Image.asset(
                        'assets/google_logo.webp',
                        height: 24,
                        width: 24,
                        errorBuilder:
                            (context, error, stackTrace) =>
                                Icon(Icons.login, color: Colors.red),
                      ),
                      label: const Text(
                        'Sign in with Google',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: const BorderSide(color: Colors.black, width: 1.5),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () async {
                        final userCred =
                            await GoogleSignInService.signInWithGoogle();
                        final firebaseUser = userCred?.user;
                        if (firebaseUser != null) {
                          final email = firebaseUser.email ?? '';
                          // Check if user exists in local DB, if not, create
                          var user = await UserDatabase.instance
                              .getUserByUsername(email);
                          if (user == null) {
                            await UserDatabase.instance.insertUser(
                              User(
                                name: firebaseUser.displayName ?? '',
                                email: email,
                                username: email,
                                password: '',
                              ),
                            );
                          }
                          // Use Firebase session as source of truth
                          widget.onLoginSuccess(email);
                        } else {
                          setState(() => _error = 'Google sign in failed');
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account?',
                          style: TextStyle(color: Colors.black87),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => SignUpPage(onSignUp: () {}),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () async {
                        await UserDatabase.instance.deleteAllUsers();
                        setState(() {
                          _error = 'All users deleted (testing)';
                        });
                      },
                      child: const Text(
                        'Delete all users (testing)',
                        style: TextStyle(color: Colors.red),
                      ),
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

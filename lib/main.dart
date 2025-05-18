import 'user_database.dart' as user_db;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'pages/expense_home_page.dart';
import 'pages/login_page.dart';
import 'pages/landing_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const RootApp());
}

const List<String> categories = [
  'Food',
  'Transport',
  'Shopping',
  'Bills',
  'Other',
];

IconData getCategoryIcon(String category) {
  switch (category) {
    case 'Food':
      return Icons.fastfood;
    case 'Transport':
      return Icons.directions_car;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Bills':
      return Icons.receipt_long;
    default:
      return Icons.category;
  }
}

class AuthService {
  static String? _currentUsername;

  static Future<bool> signUp(
    String username,
    String password, {
    String? name,
    String? email,
  }) async {
    final user = user_db.User(
      name: name ?? '',
      email: email ?? '',
      username: username,
      password: password,
    );
    final db = user_db.UserDatabase.instance;
    final existing = await db.getUserByUsername(username);
    if (existing != null) return false; // Username already exists
    await db.insertUser(user);
    _currentUsername = username;
    return true;
  }

  static Future<bool> login(String username, String password) async {
    final db = user_db.UserDatabase.instance;
    final user = await db.getUserByUsernameAndPassword(username, password);
    if (user != null) {
      _currentUsername = username;
      return true;
    }
    return false;
  }

  static String? getCurrentUsername() => _currentUsername;

  static Future<bool> isLoggedIn() async {
    return _currentUsername != null;
  }

  static Future<void> logout() async {
    _currentUsername = null;
  }
}

class RootApp extends StatefulWidget {
  const RootApp({super.key});

  @override
  State<RootApp> createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  bool _showLanding = true;
  bool _loggedIn = false;
  bool _loading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    // Check FirebaseAuth for Google login
    final firebase = await FirebaseAuth.instance.authStateChanges().first;
    if (firebase != null && firebase.email != null) {
      setState(() {
        _loggedIn = true;
        _username = firebase.email;
        _loading = false;
        _showLanding = false;
      });
      return;
    }
    setState(() {
      _loggedIn = false;
      _username = null;
      _loading = false;
    });
  }

  void _onLogin(String username) {
    setState(() {
      _loggedIn = true;
      _username = username;
    });
  }

  void _onLogout() {
    setState(() {
      _loggedIn = false;
      _username = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading)
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(
        primaryColor: Color(0xFFFFD600),
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: Color(0xFFFFD600),
          secondary: Colors.black,
          background: Colors.black,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFFD600),
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFFD600),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(),
          labelStyle: TextStyle(color: Colors.black),
        ),
      ),
      home:
          _showLanding
              ? LandingPage(
                onContinue: () => setState(() => _showLanding = false),
              )
              : _loggedIn
              ? ExpenseHomePage(username: _username!, onLogout: _onLogout)
              : LoginPage(onLoginSuccess: _onLogin),
    );
  }
}

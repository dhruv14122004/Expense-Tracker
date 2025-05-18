import 'user_database.dart';
import 'package:flutter/material.dart';
import 'pages/expense_home_page.dart';
import 'pages/login_page.dart';

void main() {
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
    final user = User(
      name: name ?? '',
      email: email ?? '',
      username: username,
      password: password,
    );
    final db = UserDatabase.instance;
    final existing = await db.getUserByUsername(username);
    if (existing != null) return false; // Username already exists
    await db.insertUser(user);
    _currentUsername = username;
    return true;
  }

  static Future<bool> login(String username, String password) async {
    final db = UserDatabase.instance;
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
  bool _loggedIn = false;
  bool _loading = true;
  String? _username;

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    _loggedIn = await AuthService.isLoggedIn();
    _username = AuthService.getCurrentUsername();
    setState(() {
      _loading = false;
    });
  }

  void _onLoginSuccess(String username) {
    setState(() {
      _loggedIn = true;
      _username = username;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        fontFamily: 'PlayfairDisplay',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF09233D),
          secondary: Color(0xFF5FCB83),
        ),
        scaffoldBackgroundColor: Color(0xFF09233D),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFAFAFA), 
            letterSpacing: 1.2,
          ),
          titleLarge: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFAFAFA), // Brighter white for contrast
          ),
          bodyLarge: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 18,
            color: Color(0xFFFAFAFA), // Brighter white for contrast
          ),
          bodyMedium: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontSize: 16,
            color: Color(0xFFB0C4DE), // Soft blue for secondary text
          ),
        ),
      ),
      home:
          _loggedIn && _username != null
              ? ExpenseHomePage(
                username: _username!,
                onLogout:
                    () => setState(() {
                      _loggedIn = false;
                      _username = null;
                    }),
              )
              : LoginPage(
                onLoginSuccess: (username) => _onLoginSuccess(username),
              ),
    );
  }
}

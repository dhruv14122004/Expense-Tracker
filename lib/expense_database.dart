import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'expense.dart';

class ExpenseDatabase {
  static final ExpenseDatabase instance = ExpenseDatabase._init();
  static Database? _database;

  ExpenseDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expenses.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, filePath);
    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        username TEXT NOT NULL
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
        'ALTER TABLE expenses ADD COLUMN username TEXT NOT NULL DEFAULT ""',
      );
    }
  }

  Future<int> insertExpense(Expense expense) async {
    final db = await instance.database;
    return await db.insert('expenses', {
      'title': expense.title,
      'amount': expense.amount,
      'date': expense.date.toIso8601String(),
      'category': expense.category,
      'username': expense.username,
    });
  }

  Future<List<Expense>> getAllExpenses() async {
    final db = await instance.database;
    final result = await db.query('expenses', orderBy: 'date DESC');
    return result
        .map(
          (json) => Expense(
            title: json['title'] as String,
            amount: json['amount'] as double,
            date: DateTime.parse(json['date'] as String),
            category: json['category'] as String,
            username: json['username'] as String,
          ),
        )
        .toList();
  }

  Future<List<Expense>> getExpensesForUser(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'expenses',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'date DESC',
    );
    return result
        .map(
          (json) => Expense(
            title: json['title'] as String,
            amount:
                json['amount'] is int
                    ? (json['amount'] as int).toDouble()
                    : json['amount'] as double,
            date: DateTime.parse(json['date'] as String),
            category: json['category'] as String,
            username: json['username'] as String,
          ),
        )
        .toList();
  }

  Future<int> deleteExpense(Expense expense) async {
    final db = await instance.database;
    return await db.delete(
      'expenses',
      where:
          'title = ? AND amount = ? AND date = ? AND category = ? AND username = ?',
      whereArgs: [
        expense.title,
        expense.amount,
        expense.date.toIso8601String(),
        expense.category,
        expense.username,
      ],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

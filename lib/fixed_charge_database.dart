import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class FixedCharge {
  final int? id;
  final String username;
  final String title;
  final double amount;

  FixedCharge({
    this.id,
    required this.username,
    required this.title,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {'id': id, 'username': username, 'title': title, 'amount': amount};
  }

  factory FixedCharge.fromMap(Map<String, dynamic> map) {
    return FixedCharge(
      id: map['id'] as int?,
      username: map['username'] as String,
      title: map['title'] as String,
      amount:
          map['amount'] is int
              ? (map['amount'] as int).toDouble()
              : map['amount'] as double,
    );
  }
}

class FixedChargeDatabase {
  static final FixedChargeDatabase instance = FixedChargeDatabase._init();
  static Database? _database;

  FixedChargeDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('fixed_charges.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE fixed_charges (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL
      )
    ''');
  }

  Future<int> insertFixedCharge(FixedCharge charge) async {
    final db = await instance.database;
    return await db.insert('fixed_charges', charge.toMap());
  }

  Future<List<FixedCharge>> getFixedChargesForUser(String username) async {
    final db = await instance.database;
    final result = await db.query(
      'fixed_charges',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.map((map) => FixedCharge.fromMap(map)).toList();
  }

  Future<void> updateFixedCharge(FixedCharge charge) async {
    final db = await instance.database;
    await db.update(
      'fixed_charges',
      charge.toMap(),
      where: 'id = ?',
      whereArgs: [charge.id],
    );
  }

  Future<void> deleteFixedCharge(int id) async {
    final db = await instance.database;
    await db.delete('fixed_charges', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}

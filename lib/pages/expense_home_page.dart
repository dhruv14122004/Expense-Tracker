import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../expense.dart';
import '../expense_database.dart';
import '../main.dart';
import '../fixed_charge_database.dart' as fixed_db;

class ExpenseHomePage extends StatefulWidget {
  final VoidCallback? onLogout;
  final String username;
  const ExpenseHomePage({super.key, required this.username, this.onLogout});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  List<Expense> _expenses = [];
  bool _loading = true;
  double monthlySalary = 50000; // Example salary, you can make this dynamic
  List<fixed_db.FixedCharge> _fixedCharges = [];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
    _loadFixedCharges();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    _expenses = await ExpenseDatabase.instance.getExpensesForUser(
      widget.username,
    );
    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadFixedCharges() async {
    _fixedCharges = await fixed_db.FixedChargeDatabase.instance
        .getFixedChargesForUser(widget.username);
    setState(() {});
  }

  double get fixedChargesTotal =>
      _fixedCharges.fold(0.0, (sum, c) => sum + c.amount);

  Future<void> _addExpense(String title, double amount, String category) async {
    final expense = Expense(
      title: title,
      amount: amount,
      date: DateTime.now(),
      category: category,
      username: widget.username,
    );
    await ExpenseDatabase.instance.insertExpense(expense);
    await _loadExpenses();
  }

  Future<void> _addFixedCharge(String title, double amount) async {
    await fixed_db.FixedChargeDatabase.instance.insertFixedCharge(
      fixed_db.FixedCharge(
        username: widget.username,
        title: title,
        amount: amount,
      ),
    );
    await _loadFixedCharges();
  }

  Future<void> _deleteExpense(Expense expense) async {
    await ExpenseDatabase.instance.deleteExpense(expense);
    await _loadExpenses();
  }

  Future<void> _deleteFixedCharge(int id) async {
    await fixed_db.FixedChargeDatabase.instance.deleteFixedCharge(id);
    await _loadFixedCharges();
  }

  void _showAddExpenseSheet() {
    String title = '';
    String amount = '';
    String category = categories[0];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Expense',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge!.copyWith(color: Colors.black),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => title = val,
                ),
                const SizedBox(height: 12),
                TextField(
                  style: const TextStyle(color: Colors.black),
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (val) => amount = val,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  items:
                      categories
                          .map(
                            (cat) => DropdownMenuItem(
                              value: cat,
                              child: Text(
                                cat,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => category = val!,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: Colors.white,
                  style: const TextStyle(color: Colors.black),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (title.isNotEmpty &&
                            double.tryParse(amount) != null) {
                          await _addExpense(
                            title,
                            double.parse(amount),
                            category,
                          );
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _showSettingsSheet() {
    String salaryInput = monthlySalary.toStringAsFixed(0);
    final fixedTitleController = TextEditingController();
    final fixedAmountController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder:
          (ctx) => StatefulBuilder(
            builder: (ctx, setModalState) {
              return Padding(
                padding: EdgeInsets.only(
                  left: 24,
                  right: 24,
                  top: 24,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Monthly Income',
                          labelStyle: TextStyle(color: Colors.black),
                          border: OutlineInputBorder(),
                        ),
                        controller: TextEditingController(text: salaryInput),
                        onChanged: (val) => salaryInput = val,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Fixed Charges',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ..._fixedCharges.map(
                        (c) => ListTile(
                          title: Text(
                            c.title,
                            style: const TextStyle(color: Colors.black),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${c.amount.toStringAsFixed(2)}',
                                style: const TextStyle(color: Colors.black),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () async {
                                  await _deleteFixedCharge(c.id!);
                                  await _loadFixedCharges();
                                  setModalState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Title',
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(color: Colors.black),
                              controller: fixedTitleController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: const InputDecoration(
                                labelText: 'Amount',
                                labelStyle: TextStyle(color: Colors.black),
                                border: OutlineInputBorder(),
                              ),
                              style: const TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              controller: fixedAmountController,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, color: Colors.teal),
                            onPressed: () async {
                              final title = fixedTitleController.text.trim();
                              final amountText =
                                  fixedAmountController.text.trim();
                              if (title.isNotEmpty &&
                                  double.tryParse(amountText) != null) {
                                await _addFixedCharge(
                                  title,
                                  double.parse(amountText),
                                );
                                await _loadFixedCharges();
                                setModalState(() {});
                                fixedTitleController.clear();
                                fixedAmountController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              final parsedSalary = double.tryParse(salaryInput);
                              if (parsedSalary != null && parsedSalary > 0) {
                                setState(() {
                                  monthlySalary = parsedSalary;
                                });
                                Navigator.of(ctx).pop();
                              }
                            },
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  double get _totalExpenses => _expenses.fold(0, (sum, e) => sum + e.amount);
  double get _availableSalary =>
      (monthlySalary - fixedChargesTotal).clamp(0, monthlySalary);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF09233D),
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (widget.onLogout != null)
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await AuthService.logout();
                if (widget.onLogout != null) widget.onLogout!();
              },
              tooltip: 'Logout',
            ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsSheet,
            tooltip: 'Settings',
          ),
        ],
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  // The original green box header with the percent bar inside
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    decoration: const BoxDecoration(
                      color: Colors.teal, // green box
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              CircularPercentIndicator(
                                radius: 90.0,
                                lineWidth: 18.0,
                                percent:
                                    (_totalExpenses + fixedChargesTotal) /
                                                monthlySalary >
                                            1
                                        ? 1
                                        : (_totalExpenses + fixedChargesTotal) /
                                            monthlySalary,
                                center: const SizedBox.shrink(),
                                progressColor:
                                    Colors
                                        .transparent, // We'll draw custom arcs
                                backgroundColor: Colors.green.shade200,
                                circularStrokeCap: CircularStrokeCap.round,
                                animation: true,
                              ),
                              SizedBox(
                                width: 180,
                                height: 180,
                                child: CustomPaint(
                                  painter: _ExpenseArcPainter(
                                    _expenses,
                                    monthlySalary,
                                    fixedChargesTotal: fixedChargesTotal,
                                    fixedChargesList: _fixedCharges,
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '₹${(_availableSalary - _totalExpenses).clamp(0, monthlySalary).toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'remaining',
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Total Expenses',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: _totalExpenses),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOut,
                          builder:
                              (context, value, child) => Text(
                                '₹${value.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _expenses.isEmpty
                            ? Center(
                              child: AnimatedOpacity(
                                opacity: _expenses.isEmpty ? 1.0 : 0.0,
                                duration: const Duration(milliseconds: 600),
                                child: Text(
                                  'No expenses yet.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            )
                            : ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: _expenses.length,
                              itemBuilder: (ctx, i) {
                                final e = _expenses[i];
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  margin: const EdgeInsets.only(bottom: 16),
                                  child: Dismissible(
                                    key: ValueKey(e.hashCode),
                                    direction: DismissDirection.endToStart,
                                    background: Container(
                                      alignment: Alignment.centerRight,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                      ),
                                      color: Colors.redAccent,
                                      child: const Icon(
                                        Icons.delete,
                                        color: Colors.white,
                                      ),
                                    ),
                                    onDismissed: (_) async {
                                      await _deleteExpense(e);
                                    },
                                    child: Card(
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.teal.shade100,
                                          child: Icon(
                                            getCategoryIcon(e.category),
                                            color: Colors.teal,
                                          ),
                                        ),
                                        title: Text(
                                          e.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(color: Colors.black),
                                        ),
                                        subtitle: Text(
                                          '${e.category} • ${e.date.day}/${e.date.month}/${e.date.year}',
                                        ),
                                        trailing: Text(
                                          '-₹${e.amount.toStringAsFixed(2)}',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyLarge!.copyWith(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExpenseSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
        backgroundColor: Colors.teal,
      ),
    );
  }
}

class _ExpenseArcPainter extends CustomPainter {
  final List<Expense> expenses;
  final double salary;
  final double fixedChargesTotal;
  final List<fixed_db.FixedCharge> fixedChargesList;
  _ExpenseArcPainter(
    this.expenses,
    this.salary, {
    this.fixedChargesTotal = 0,
    this.fixedChargesList = const [],
  });

  static const Map<String, Color> categoryColors = {
    'Food': Colors.red,
    'Transport': Colors.blue,
    'Shopping': Colors.purple,
    'Bills': Colors.orange,
    'Other': Colors.teal,
  };

  static final List<Color> fixedChargeColors = [
    Colors.grey,
    Colors.blueGrey,
    Colors.brown,
    Colors.indigo,
    Colors.cyan,
    Colors.deepOrange,
    Colors.amber,
    Colors.green,
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 18.0;
    final radius = (size.width / 2) - (strokeWidth / 2);
    final center = Offset(size.width / 2, size.height / 2);
    double startAngle = -3.14159 / 2; // Start at top
    if (salary == 0) return;
    // Draw each fixed charge arc
    for (int i = 0; i < fixedChargesList.length; i++) {
      final fc = fixedChargesList[i];
      if (fc.amount <= 0) continue;
      final sweep = (fc.amount / salary) * 3.14159 * 2;
      final paint =
          Paint()
            ..color = fixedChargeColors[i % fixedChargeColors.length]
                .withOpacity(0.7)
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
    // Draw category arcs
    for (final cat in categoryColors.keys) {
      final catTotal = expenses
          .where((e) => e.category == cat)
          .fold(0.0, (sum, e) => sum + e.amount);
      if (catTotal == 0) continue;
      final sweep = (catTotal / salary) * 3.14159 * 2;
      final paint =
          Paint()
            ..color = categoryColors[cat]!
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

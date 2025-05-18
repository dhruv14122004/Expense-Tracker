import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../expense.dart';
import '../expense_database.dart';
import '../main.dart';
import '../fixed_charge_database.dart' as fixed_db;

final Color kYellow = Color(0xFFFFD600);
final Color kBlack = Colors.black;
final Color kWhite = Colors.white;

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
                  ).textTheme.titleLarge!.copyWith(color: kBlack),
                ),
                const SizedBox(height: 16),
                TextField(
                  style: TextStyle(color: kBlack),
                  decoration: InputDecoration(
                    labelText: 'Title',
                    labelStyle: TextStyle(color: kBlack),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => title = val,
                ),
                const SizedBox(height: 12),
                TextField(
                  style: TextStyle(color: kBlack),
                  decoration: InputDecoration(
                    labelText: 'Amount',
                    labelStyle: TextStyle(color: kBlack),
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
                              child: Text(cat, style: TextStyle(color: kBlack)),
                            ),
                          )
                          .toList(),
                  onChanged: (val) => category = val!,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    labelStyle: TextStyle(color: kBlack),
                    border: OutlineInputBorder(),
                  ),
                  dropdownColor: kWhite,
                  style: TextStyle(color: kBlack),
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
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: kBlack,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: Colors.black),
                        decoration: InputDecoration(
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
                          title: Text(c.title, style: TextStyle(color: kBlack)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '₹${c.amount.toStringAsFixed(2)}',
                                style: TextStyle(color: kBlack),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
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
                              decoration: InputDecoration(
                                labelText: 'Title',
                                labelStyle: TextStyle(color: kBlack),
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(color: kBlack),
                              controller: fixedTitleController,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                labelText: 'Amount',
                                labelStyle: TextStyle(color: kBlack),
                                border: OutlineInputBorder(),
                              ),
                              style: TextStyle(color: kBlack),
                              keyboardType: TextInputType.number,
                              controller: fixedAmountController,
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.add, color: kYellow),
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
      backgroundColor: kBlack,
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        backgroundColor: kYellow,
        foregroundColor: kBlack,
        elevation: 0,
        actions: [
          if (widget.onLogout != null)
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await AuthService.logout();
                if (widget.onLogout != null) widget.onLogout!();
              },
              tooltip: 'Logout',
            ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: _showSettingsSheet,
            tooltip: 'Settings',
          ),
        ],
      ),
      body:
          _loading
              ? Center(child: CircularProgressIndicator(color: kYellow))
              : Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeInOut,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 24,
                    ),
                    decoration: BoxDecoration(
                      color: kYellow,
                      borderRadius: const BorderRadius.vertical(
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
                                progressColor: Colors.transparent,
                                backgroundColor: kWhite,
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
                                    style: TextStyle(
                                      color: kBlack,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'remaining',
                                    style: TextStyle(
                                      color: kBlack.withOpacity(0.7),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Total Expenses',
                          style: TextStyle(
                            color: kBlack.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: _totalExpenses),
                          duration: const Duration(milliseconds: 900),
                          curve: Curves.easeOut,
                          builder:
                              (context, value, child) => Text(
                                '₹${value.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: kBlack,
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
                                  style: Theme.of(context).textTheme.bodyLarge!
                                      .copyWith(color: kWhite),
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
                                      color: kYellow,
                                      child: Icon(Icons.delete, color: kBlack),
                                    ),
                                    onDismissed: (_) async {
                                      await _deleteExpense(e);
                                    },
                                    child: Card(
                                      color: kWhite,
                                      elevation: 2,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: kYellow,
                                          child: Icon(
                                            getCategoryIcon(e.category),
                                            color: kBlack,
                                          ),
                                        ),
                                        title: Text(
                                          e.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(color: kBlack),
                                        ),
                                        subtitle: Text(
                                          '${e.category} • ${e.date.day}/${e.date.month}/${e.date.year}',
                                          style: TextStyle(
                                            color: kBlack.withOpacity(0.7),
                                          ),
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
        icon: Icon(Icons.add, color: kBlack),
        label: Text('Add Expense', style: TextStyle(color: kBlack)),
        backgroundColor: kYellow,
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
    'Food': Color(0xFFFFD600), // yellow
    'Transport': Color(0xFF212121), // black
    'Shopping': Color(0xFFFFFFFF), // white
    'Bills': Color(0xFFFFF176), // light yellow
    'Other': Color(0xFF757575), // dark grey
  };

  static final List<Color> fixedChargeColors = [
    Color(0xFFFFD600),
    Color(0xFF212121),
    Color(0xFFFFFFFF),
    Color(0xFFFFF176),
    Color(0xFF757575),
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

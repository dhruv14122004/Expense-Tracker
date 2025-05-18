class Expense {
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final String username; // Add username field

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.username, // Add username to constructor
  });
}

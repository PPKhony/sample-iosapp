import 'package:flutter/foundation.dart';
import '../models/transaction.dart';

class AppState extends ChangeNotifier {
  final List<Transaction> _transactions = [];

  AppState() {
    _populateMockData();
  }

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  List<Transaction> get expenses =>
      _transactions.where((t) => t.isExpense).toList();

  List<Transaction> get income =>
      _transactions.where((t) => !t.isExpense).toList();

  double get totalIncome {
    return income.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get totalExpenses {
    return expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  double get netBalance => totalIncome - totalExpenses;

  // Group transactions by date for the history list
  Map<DateTime, List<Transaction>> get transactionsGroupedByDate {
    final Map<DateTime, List<Transaction>> groups = {};
    for (var tx in _transactions) {
      final dateOnly = DateTime(tx.date.year, tx.date.month, tx.date.day);
      if (!groups.containsKey(dateOnly)) {
        groups[dateOnly] = [];
      }
      groups[dateOnly]!.add(tx);
    }

    // Sort dates descending
    final sortedKeys = groups.keys.toList()
      ..sort((a, b) => b.compareTo(a));
    
    final Map<DateTime, List<Transaction>> sortedGroups = {};
    for (var key in sortedKeys) {
      // Sort transactions inside each day by time descending
      final dayTx = groups[key]!..sort((a, b) => b.date.compareTo(a.date));
      sortedGroups[key] = dayTx;
    }
    return sortedGroups;
  }

  // Calculate percentage per category for the donut chart
  Map<String, double> get expensesByCategory {
    final Map<String, double> categorySums = {};
    double total = 0.0;

    for (var tx in expenses) {
      categorySums[tx.category] = (categorySums[tx.category] ?? 0.0) + tx.amount;
      total += tx.amount;
    }

    if (total == 0.0) return {};

    // Convert to percentage
    return categorySums.map((key, value) => MapEntry(key, value / total));
  }

  // Calculate total amount per category
  Map<String, double> get categoryExpenseTotals {
    final Map<String, double> totals = {};
    for (var tx in expenses) {
      totals[tx.category] = (totals[tx.category] ?? 0.0) + tx.amount;
    }
    return totals;
  }

  void addTransaction(Transaction transaction) {
    _transactions.add(transaction);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void deleteTransaction(String id) {
    _transactions.removeWhere((tx) => tx.id == id);
    notifyListeners();
  }

  void _populateMockData() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _transactions.addAll([
      // Today's transactions
      Transaction(
        id: 'tx1',
        title: 'ซูชิคำโต (Sushi Buffet)',
        amount: 1200.0,
        date: today.add(const Duration(hours: 19, minutes: 30)),
        category: 'Food & Drinks',
        isExpense: true,
      ),
      Transaction(
        id: 'tx2',
        title: 'สตาร์บัคส์ ลาเต้ (Starbucks)',
        amount: 185.0,
        date: today.add(const Duration(hours: 14, minutes: 15)),
        category: 'Food & Drinks',
        isExpense: true,
      ),
      Transaction(
        id: 'tx3',
        title: 'ค่าบริการแท็กซี่ (Taxi)',
        amount: 230.0,
        date: today.add(const Duration(hours: 9, minutes: 0)),
        category: 'Transportation',
        isExpense: true,
      ),
      // Yesterday's transactions
      Transaction(
        id: 'tx4',
        title: 'เดินทางบีทีเอส (BTS Sky Train)',
        amount: 120.0,
        date: today.subtract(const Duration(days: 1)).add(const Duration(hours: 18, minutes: 0)),
        category: 'Transportation',
        isExpense: true,
      ),
      Transaction(
        id: 'tx5',
        title: 'เคส iPhone ของแท้ Apple Store',
        amount: 1990.0,
        date: today.subtract(const Duration(days: 1)).add(const Duration(hours: 13, minutes: 45)),
        category: 'Shopping',
        isExpense: true,
      ),
      // 3 days ago
      Transaction(
        id: 'tx6',
        title: 'เงินเดือน (Salary)',
        amount: 54000.0,
        date: today.subtract(const Duration(days: 3)).add(const Duration(hours: 10, minutes: 0)),
        category: 'Salary',
        isExpense: false,
      ),
      Transaction(
        id: 'tx7',
        title: 'ค่าสมาชิก Netflix รายเดือน',
        amount: 419.0,
        date: today.subtract(const Duration(days: 3)).add(const Duration(hours: 8, minutes: 15)),
        category: 'Entertainment',
        isExpense: true,
        isMonthlyRecurring: true,
      ),
      // 4 days ago
      Transaction(
        id: 'tx8',
        title: 'บิลค่าไฟฟ้า (MEA Bill)',
        amount: 2450.0,
        date: today.subtract(const Duration(days: 4)).add(const Duration(hours: 11, minutes: 30)),
        category: 'Bills & Utilities',
        isExpense: true,
        isMonthlyRecurring: true,
      ),
      // 5 days ago
      Transaction(
        id: 'tx9',
        title: 'เงินค่าเขียนโปรแกรม Freelance',
        amount: 8500.0,
        date: today.subtract(const Duration(days: 5)).add(const Duration(hours: 16, minutes: 0)),
        category: 'Side Hustle',
        isExpense: false,
      ),
      // 6 days ago
      Transaction(
        id: 'tx10',
        title: 'ลงทุนใน Bitcoin DCA',
        amount: 3000.0,
        date: today.subtract(const Duration(days: 6)).add(const Duration(hours: 12, minutes: 0)),
        category: 'Investment',
        isExpense: true,
      ),
    ]);

    // Sort initially by date descending
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }
}

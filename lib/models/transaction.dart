import 'package:flutter/cupertino.dart';

enum TransactionCategory {
  foodAndDrinks(name: 'Food & Drinks', icon: CupertinoIcons.square_grid_2x2),
  shopping(name: 'Shopping', icon: CupertinoIcons.bag),
  transportation(name: 'Transportation', icon: CupertinoIcons.car),
  entertainment(name: 'Entertainment', icon: CupertinoIcons.gamecontroller),
  bills(name: 'Bills & Utilities', icon: CupertinoIcons.doc_text),
  investment(name: 'Investment', icon: CupertinoIcons.chart_bar),
  salary(name: 'Salary', icon: CupertinoIcons.money_dollar),
  sideHustle(name: 'Side Hustle', icon: CupertinoIcons.briefcase),
  other(name: 'Other', icon: CupertinoIcons.question_circle);

  final String name;
  final IconData icon;

  const TransactionCategory({required this.name, required this.icon});

  static TransactionCategory fromString(String value) {
    return TransactionCategory.values.firstWhere(
      (element) => element.name == value,
      orElse: () => TransactionCategory.other,
    );
  }
}

class Transaction {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final String category;
  final bool isExpense;
  final bool isMonthlyRecurring;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    required this.isExpense,
    this.isMonthlyRecurring = false,
  });

  Transaction copyWith({
    String? id,
    String? title,
    double? amount,
    DateTime? date,
    String? category,
    bool? isExpense,
    bool? isMonthlyRecurring,
  }) {
    return Transaction(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      isExpense: isExpense ?? this.isExpense,
      isMonthlyRecurring: isMonthlyRecurring ?? this.isMonthlyRecurring,
    );
  }
}

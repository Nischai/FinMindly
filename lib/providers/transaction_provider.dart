import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';

class TransactionProvider with ChangeNotifier {
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  // Get all unique tags across all transactions
  Set<String> get allTags {
    final Set<String> tags = {};
    for (final transaction in _transactions) {
      tags.addAll(transaction.tags);
    }
    return tags;
  }

  Future<void> setTransactions(List<Transaction> transactions) async {
    _transactions = transactions;
    await _saveTransactions();
    notifyListeners();
  }

  // Add a single transaction to the list
  Future<void> addTransaction(Transaction transaction) async {
    // Check if transaction with same ID already exists
    final existingIndex =
        _transactions.indexWhere((t) => t.id == transaction.id);

    if (existingIndex >= 0) {
      // Transaction already exists, don't add duplicate
      return;
    }

    _transactions.add(transaction);
    await _saveTransactions();
    notifyListeners();
  }

  // Add a tag to a transaction
  Future<void> addTagToTransaction(String transactionId, String tag) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = _transactions[index];
      if (!transaction.tags.contains(tag)) {
        final updatedTags = List<String>.from(transaction.tags)..add(tag);
        _transactions[index] = transaction.copyWith(tags: updatedTags);
        await _saveTransactions();
        notifyListeners();
      }
    }
  }

  // Remove a tag from a transaction
  Future<void> removeTagFromTransaction(
      String transactionId, String tag) async {
    final index = _transactions.indexWhere((t) => t.id == transactionId);
    if (index != -1) {
      final transaction = _transactions[index];
      if (transaction.tags.contains(tag)) {
        final updatedTags = List<String>.from(transaction.tags)..remove(tag);
        _transactions[index] = transaction.copyWith(tags: updatedTags);
        await _saveTransactions();
        notifyListeners();
      }
    }
  }

  // Get transactions filtered by tags
  List<Transaction> getTransactionsByTags(List<String> tags) {
    if (tags.isEmpty) return _transactions;

    return _transactions.where((transaction) {
      return tags.any((tag) => transaction.tags.contains(tag));
    }).toList();
  }

  Future<void> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString('transactions');

    if (transactionsJson != null) {
      try {
        final List<dynamic> decodedList = json.decode(transactionsJson);
        _transactions =
            decodedList.map((item) => Transaction.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading transactions: $e');
      }
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(_transactions.map((item) => item.toJson()).toList());
    await prefs.setString('transactions', encodedData);
  }

  // Get daily transactions for statistics
  Map<String, double> getDailyExpenses({int daysBack = 7}) {
    final Map<String, double> dailyExpenses = {};
    final now = DateTime.now();

    for (int i = daysBack - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayString = DateFormat('MM/dd').format(day);
      dailyExpenses[dayString] = 0;
    }

    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        final difference = now.difference(transaction.date).inDays;
        if (difference < daysBack) {
          final dayString = DateFormat('MM/dd').format(transaction.date);
          dailyExpenses.update(
            dayString,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }
      }
    }

    return dailyExpenses;
  }

  // Get daily income for statistics
  Map<String, double> getDailyIncome({int daysBack = 7}) {
    final Map<String, double> dailyIncome = {};
    final now = DateTime.now();

    for (int i = daysBack - 1; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final dayString = DateFormat('MM/dd').format(day);
      dailyIncome[dayString] = 0;
    }

    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.income) {
        final difference = now.difference(transaction.date).inDays;
        if (difference < daysBack) {
          final dayString = DateFormat('MM/dd').format(transaction.date);
          dailyIncome.update(
            dayString,
            (value) => value + transaction.amount,
            ifAbsent: () => transaction.amount,
          );
        }
      }
    }

    return dailyIncome;
  }

  // Get expenses by category
  Map<String, double> getExpensesByCategory() {
    final Map<String, double> categoryExpenses = {};

    for (final transaction in _transactions) {
      if (transaction.type == TransactionType.expense) {
        categoryExpenses.update(
          transaction.category,
          (value) => value + transaction.amount,
          ifAbsent: () => transaction.amount,
        );
      }
    }

    return categoryExpenses;
  }

  // Get total expenses and income
  double getTotalExpenses() {
    return _transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }

  double getTotalIncome() {
    return _transactions
        .where((t) => t.type == TransactionType.income)
        .fold(0, (sum, transaction) => sum + transaction.amount);
  }
}

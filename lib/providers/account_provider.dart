import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/account.dart';
import '../models/transaction.dart';

class AccountProvider with ChangeNotifier {
  List<Account> _accounts = [];

  List<Account> get accounts => _accounts;

  Future<void> loadAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? accountsJson = prefs.getString('accounts');

    if (accountsJson != null) {
      try {
        final List<dynamic> decodedList = json.decode(accountsJson);
        _accounts = decodedList.map((item) => Account.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        debugPrint('Error loading accounts: $e');
      }
    } else {
      // Initialize with some default accounts if none exist
      _initializeDefaultAccounts();
    }
  }

  Future<void> _saveAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(_accounts.map((item) => item.toJson()).toList());
    await prefs.setString('accounts', encodedData);
  }

  Future<void> addAccount(Account account) async {
    _accounts.add(account);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> updateAccount(Account account) async {
    final index = _accounts.indexWhere((a) => a.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
      await _saveAccounts();
      notifyListeners();
    }
  }

  Future<void> deleteAccount(String accountId) async {
    _accounts.removeWhere((account) => account.id == accountId);
    await _saveAccounts();
    notifyListeners();
  }

  Future<void> clearAccounts() async {
    _accounts = [];
    await _saveAccounts();
    notifyListeners();
  }

  // Extract account information from transactions
  Future<void> extractAccountsFromTransactions(
      List<Transaction> transactions) async {
    Map<String, Map<String, dynamic>> accountMap = {};

    // First pass: identify potential accounts from transaction descriptions
    for (final transaction in transactions) {
      final description = transaction.description.toUpperCase();

      // Look for bank names in the description
      List<String> possibleBanks = [
        'HDFC',
        'SBI',
        'ICICI',
        'AXIS',
        'KOTAK',
        'PNB',
        'BOI',
        'YES BANK',
        'CANARA',
        'CENTRAL',
        'INDIAN',
        'UCO',
        'SYNDICATE',
        'IDBI',
        'BOB'
      ];

      String? bankName;
      String? lastFour;

      // Try to extract card/account numbers (last 4 digits)
      RegExp cardRegex = RegExp(r'[Xx*]+(\d{4})');
      var cardMatch = cardRegex.firstMatch(description);
      if (cardMatch != null && cardMatch.groupCount >= 1) {
        lastFour = cardMatch.group(1);
      }

      // Try to identify bank name
      for (var bank in possibleBanks) {
        if (description.contains(bank)) {
          bankName = bank;
          break;
        }
      }

      // Determine account type
      AccountType accountType = AccountType.other;
      if (description.contains('CREDIT CARD') || description.contains('CC')) {
        accountType = AccountType.creditCard;
      } else if (description.contains('DEBIT CARD') ||
          description.contains('DC')) {
        accountType = AccountType.debitCard;
      } else if (bankName != null) {
        accountType = AccountType.bank;
      } else if (description.contains('INVEST') ||
          description.contains('STOCK') ||
          description.contains('SHARE') ||
          description.contains('MUTUAL FUND')) {
        accountType = AccountType.investment;
      } else if (description.contains('INSURANCE') ||
          description.contains('POLICY')) {
        accountType = AccountType.insurance;
      }

      // Create a unique identifier for this account
      String accountId;
      if (bankName != null && lastFour != null) {
        accountId = '${bankName}_$lastFour';
      } else if (bankName != null) {
        accountId = bankName;
      } else if (accountType == AccountType.investment) {
        accountId = 'investment_${description.hashCode}';
      } else if (accountType == AccountType.insurance) {
        accountId = 'insurance_${description.hashCode}';
      } else {
        continue; // Skip if we can't identify an account
      }

      // Update or create account data
      if (!accountMap.containsKey(accountId)) {
        accountMap[accountId] = {
          'id': accountId,
          'name': bankName ?? 'Account',
          'type': accountType,
          'lastFourDigits': lastFour,
          'bankName': bankName,
          'balance': 0.0,
          'transactions': <Transaction>[],
        };
      }

      // Add this transaction to the account
      accountMap[accountId]!['transactions'].add(transaction);
    }

    // Second pass: calculate balances for each account
    List<Account> extractedAccounts = [];
    accountMap.forEach((key, data) {
      List<Transaction> accountTransactions = data['transactions'];
      double balance = 0.0;

      for (var transaction in accountTransactions) {
        if (transaction.type == TransactionType.income) {
          balance += transaction.amount;
        } else {
          balance -= transaction.amount;
        }
      }

      extractedAccounts.add(Account(
        id: data['id'],
        name: data['name'],
        type: data['type'],
        lastFourDigits: data['lastFourDigits'],
        balance: balance,
        bankName: data['bankName'],
      ));
    });

    // Update our accounts list, but preserve existing accounts
    for (var newAccount in extractedAccounts) {
      final existingIndex = _accounts.indexWhere((a) => a.id == newAccount.id);
      if (existingIndex == -1) {
        _accounts.add(newAccount);
      } else {
        // Update balance but keep other customizations
        final existing = _accounts[existingIndex];
        _accounts[existingIndex] = Account(
          id: existing.id,
          name: existing.name,
          logo: existing.logo,
          type: existing.type,
          lastFourDigits: existing.lastFourDigits,
          balance: newAccount.balance,
          bankName: existing.bankName,
          color: existing.color,
        );
      }
    }

    await _saveAccounts();
    notifyListeners();
  }

  void _initializeDefaultAccounts() {
    // Start with empty accounts - they'll be extracted from transactions
    _accounts = [];
    _saveAccounts();
  }
}

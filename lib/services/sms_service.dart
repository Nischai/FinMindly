import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';

class SMSService {
  final SmsQuery _query = SmsQuery();

  // Bank sender IDs - Add more as needed
  final List<String> _bankSenders = [
    'HDFCBK',
    'SBIINB',
    'ICICIB',
    'AXISBK',
    'KOTAKB',
    'PNBSMS',
    'BOIIND',
    'YESBK',
    'CANBNK',
    'CENTBK',
    'INDBNK',
    'UCOBNK',
    'SYNBNK',
    'IDBI',
    'BOBACC',
  ];

  // Map bank sender IDs to bank names
  final Map<String, String> _bankNameMap = {
    'HDFCBK': 'HDFC Bank',
    'SBIINB': 'SBI',
    'ICICIB': 'ICICI Bank',
    'AXISBK': 'Axis Bank',
    'KOTAKB': 'Kotak Bank',
    'PNBSMS': 'PNB',
    'BOIIND': 'Bank of India',
    'YESBK': 'Yes Bank',
    'CANBNK': 'Canara Bank',
    'CENTBK': 'Central Bank',
    'INDBNK': 'Indian Bank',
    'UCOBNK': 'UCO Bank',
    'SYNBNK': 'Syndicate Bank',
    'IDBI': 'IDBI Bank',
    'BOBACC': 'Bank of Baroda',
  };

  Future<void> loadMessages(BuildContext context) async {
    try {
      final messages = await _query.querySms(
        kinds: [SmsQueryKind.inbox],
        count: 500, // Limit to last 500 messages for performance
      );

      final bankMessages = messages
          .where((message) => _bankSenders.any((bank) =>
              message.sender != null && message.sender!.contains(bank)))
          .toList();

      final transactions = _parseTransactions(bankMessages);

      // Update the provider with the transactions
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.setTransactions(transactions);

      // Extract accounts from transactions
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      await accountProvider.extractAccountsFromTransactions(transactions);
    } catch (e) {
      debugPrint('Error loading SMS messages: $e');
    }
  }

  List<Transaction> _parseTransactions(List<SmsMessage> messages) {
    final List<Transaction> transactions = [];

    for (final message in messages) {
      if (message.body == null) continue;

      final String body = message.body!.toUpperCase();
      final DateTime date = message.date ?? DateTime.now();
      final String? sender = message.sender;

      // Extract bank name from sender
      String? bankName;
      if (sender != null) {
        for (final bankCode in _bankSenders) {
          if (sender.contains(bankCode)) {
            bankName = _bankNameMap[bankCode] ?? bankCode;
            break;
          }
        }
      }

      // Extract card number if present
      String? cardNumber;
      final RegExp cardRegex = RegExp(r'[Xx*]+(\d{4})');
      final cardMatch = cardRegex.firstMatch(body);
      if (cardMatch != null && cardMatch.groupCount >= 1) {
        cardNumber = cardMatch.group(1);
      }

      // Pattern 1: Debited/Credited to account
      if (_containsAnyWord(
          body, ['DEBITED', 'DEBIT', 'SPENT', 'WITHDREW', 'PAID'])) {
        final double? amount = _extractAmount(body);
        if (amount != null) {
          transactions.add(
            Transaction(
              id: message.id.toString(),
              date: date,
              amount: amount,
              type: TransactionType.expense,
              description: _extractDescription(body, bankName, cardNumber),
              category: _categorizeExpense(body),
              tags: _extractTags(body, bankName, cardNumber),
            ),
          );
        }
      } else if (_containsAnyWord(
          body, ['CREDITED', 'CREDIT', 'RECEIVED', 'DEPOSITED', 'REFUND'])) {
        final double? amount = _extractAmount(body);
        if (amount != null) {
          transactions.add(
            Transaction(
              id: message.id.toString(),
              date: date,
              amount: amount,
              type: TransactionType.income,
              description: _extractDescription(body, bankName, cardNumber),
              category: _categorizeIncome(body),
              tags: _extractTags(body, bankName, cardNumber),
            ),
          );
        }
      }
    }

    return transactions;
  }

  bool _containsAnyWord(String text, List<String> words) {
    return words.any((word) => text.contains(word));
  }

  double? _extractAmount(String text) {
    // Look for patterns like INR 1,234.56 or RS 1,234.56 or Rs.1,234.56
    final RegExp amountRegExp =
        RegExp(r'(?:INR|RS\.?|₹)\s*([0-9,.]+)', caseSensitive: false);
    final match = amountRegExp.firstMatch(text);

    if (match != null && match.groupCount >= 1) {
      String amountStr = match.group(1)!.replaceAll(',', '');
      return double.tryParse(amountStr);
    }

    return null;
  }

  String _extractDescription(
      String text, String? bankName, String? cardNumber) {
    // Look for common description indicators
    final List<String> indicators = [
      'AT',
      'TO',
      'FOR',
      'BY',
      'VIA',
      'FROM',
      'TOWARDS'
    ];

    for (final indicator in indicators) {
      final pattern = indicator + '\\s+([A-Z0-9\\s]+)';
      final RegExp descRegExp = RegExp(pattern, caseSensitive: false);
      final match = descRegExp.firstMatch(text);

      if (match != null && match.groupCount >= 1) {
        return match.group(1)!.trim();
      }
    }

    // If no specific description found, return a segment of the message
    final words = text.split(' ');
    if (words.length > 5) {
      return words.sublist(0, 5).join(' ') + '...';
    }

    return 'Transaction';
  }

  // Extract tags including bank name and card number
  List<String> _extractTags(String text, String? bankName, String? cardNumber) {
    List<String> tags = [];

    if (bankName != null) {
      tags.add(bankName);
    }

    if (cardNumber != null) {
      if (text.contains('CREDIT CARD') || text.contains('CC')) {
        tags.add('Credit Card ••••$cardNumber');
      } else if (text.contains('DEBIT CARD') || text.contains('DC')) {
        tags.add('Debit Card ••••$cardNumber');
      } else {
        tags.add('Card ••••$cardNumber');
      }
    }

    return tags;
  }

  String _categorizeExpense(String text) {
    final Map<String, List<String>> categories = {
      'Food & Dining': [
        'RESTAURANT',
        'CAFE',
        'FOOD',
        'SWIGGY',
        'ZOMATO',
        'DINING'
      ],
      'Shopping': [
        'AMAZON',
        'FLIPKART',
        'MYNTRA',
        'RETAIL',
        'STORE',
        'SHOPPING'
      ],
      'Transportation': [
        'UBER',
        'OLA',
        'CAB',
        'METRO',
        'FUEL',
        'PETROL',
        'DIESEL'
      ],
      'Entertainment': ['MOVIE', 'NETFLIX', 'PRIME', 'HOTSTAR', 'TICKET'],
      'Utilities': [
        'ELECTRICITY',
        'WATER',
        'GAS',
        'BILL',
        'RECHARGE',
        'MOBILE'
      ],
      'Health': ['HOSPITAL', 'MEDICAL', 'PHARMACY', 'DOCTOR', 'MEDICINE'],
      'Education': ['COURSE', 'TUITION', 'SCHOOL', 'COLLEGE', 'UNIVERSITY'],
      'Travel': ['HOTEL', 'FLIGHT', 'BOOKING', 'VACATION', 'TRIP'],
    };

    for (final category in categories.keys) {
      if (categories[category]!.any((word) => text.contains(word))) {
        return category;
      }
    }

    return 'Others';
  }

  String _categorizeIncome(String text) {
    final Map<String, List<String>> categories = {
      'Salary': ['SALARY', 'WAGE', 'INCOME', 'PAY'],
      'Refund': ['REFUND', 'RETURN', 'CASHBACK'],
      'Investment': ['DIVIDEND', 'INTEREST', 'MUTUAL FUND', 'STOCK'],
      'Gift': ['GIFT', 'REWARD', 'BONUS'],
    };

    for (final category in categories.keys) {
      if (categories[category]!.any((word) => text.contains(word))) {
        return category;
      }
    }

    return 'Other Income';
  }
}

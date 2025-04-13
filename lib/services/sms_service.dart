import 'package:flutter/material.dart';
import 'package:flutter_sms_inbox/flutter_sms_inbox.dart';
import 'package:provider/provider.dart';
import 'package:telephony/telephony.dart' as tp;
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';

class SMSService {
  final SmsQuery _query = SmsQuery();
  final tp.Telephony _telephony = tp.Telephony.instance;

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

  // Start listening for new SMS messages
  Future<void> startListening(BuildContext context) async {
    // Request SMS permissions first
    final bool? permissionsGranted =
        await _telephony.requestPhoneAndSmsPermissions;

    if (permissionsGranted != true) {
      debugPrint('SMS permissions not granted');
      return;
    }

    // Listen for incoming SMS messages
    _telephony.listenIncomingSms(
      onNewMessage: (tp.SmsMessage message) {
        // Check if this is a financial message
        if (_isFinancialMessage(message.address ?? '')) {
          debugPrint('Received new financial SMS: ${message.address}');

          // Process this single message
          final transaction = _parseSingleSmsMessage(message.address ?? '',
              message.body ?? '', DateTime.now(), message.id.toString());

          if (transaction != null) {
            _processNewTransaction(context, transaction);
          }
        }
      },
      listenInBackground: false, // Don't listen when app is closed
    );

    debugPrint('Started listening for new SMS messages');
  }

  // Check if sender is a financial institution
  bool _isFinancialMessage(String sender) {
    return _bankSenders.any((bank) => sender.contains(bank));
  }

  // Stop listening for new messages
  void stopListening() {
    // No explicit stop method in telephony package
    debugPrint('Stopped listening for SMS messages');
  }

  // Process and add a new transaction to providers
  Future<void> _processNewTransaction(
      BuildContext context, Transaction transaction) async {
    try {
      // Add the transaction to the provider
      final transactionProvider =
          Provider.of<TransactionProvider>(context, listen: false);
      await transactionProvider.addTransaction(transaction);

      // Update accounts based on the new transaction
      final accountProvider =
          Provider.of<AccountProvider>(context, listen: false);
      await accountProvider.extractAccountsFromTransactions([transaction]);

      // Show notification to user (could be implemented with a callback)
      debugPrint(
          'New transaction added: ${transaction.amount} - ${transaction.description}');
    } catch (e) {
      debugPrint('Error processing new transaction: $e');
    }
  }

  // Parse a single SMS message from the telephony package
  Transaction? _parseSingleSmsMessage(
    String sender,
    String body,
    DateTime date,
    String id,
  ) {
    if (body.isEmpty) return null;

    final String upperBody = body.toUpperCase();

    // Extract bank name from sender
    String? bankName;
    for (final bankCode in _bankSenders) {
      if (sender.contains(bankCode)) {
        bankName = _bankNameMap[bankCode] ?? bankCode;
        break;
      }
    }

    // Extract card number if present
    String? cardNumber;
    final RegExp cardRegex = RegExp(r'[Xx*]+(\d{4})');
    final cardMatch = cardRegex.firstMatch(upperBody);
    if (cardMatch != null && cardMatch.groupCount >= 1) {
      cardNumber = cardMatch.group(1);
    }

    // Process transaction type and amount
    if (_containsAnyWord(
        upperBody, ['DEBITED', 'DEBIT', 'SPENT', 'WITHDREW', 'PAID', 'SENT'])) {
      final double? amount = _extractAmount(upperBody);
      if (amount != null) {
        return Transaction(
          id: id,
          date: date,
          amount: amount,
          type: TransactionType.expense,
          description: _extractDescription(upperBody, bankName, cardNumber),
          category: _categorizeExpense(upperBody),
          tags: _extractTags(upperBody, bankName, cardNumber),
        );
      }
    } else if (_containsAnyWord(
        upperBody, ['CREDITED', 'CREDIT', 'RECEIVED', 'DEPOSITED', 'REFUND'])) {
      final double? amount = _extractAmount(upperBody);
      if (amount != null) {
        return Transaction(
          id: id,
          date: date,
          amount: amount,
          type: TransactionType.income,
          description: _extractDescription(upperBody, bankName, cardNumber),
          category: _categorizeIncome(upperBody),
          tags: _extractTags(upperBody, bankName, cardNumber),
        );
      }
    }

    return null;
  }

  // Parse a single SMS message from the flutter_sms_inbox package
  Transaction? _parseSingleMessage(SmsMessage message) {
    if (message.body == null || message.sender == null) return null;

    return _parseSingleSmsMessage(
      message.sender!,
      message.body!,
      message.date ?? DateTime.now(),
      message.id.toString(),
    );
  }

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
      final transaction = _parseSingleMessage(message);
      if (transaction != null) {
        transactions.add(transaction);
      }
    }

    return transactions;
  }

  bool _containsAnyWord(String text, List<String> words) {
    return words.any((word) => text.toLowerCase().contains(word.toLowerCase()));
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

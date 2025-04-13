import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/account.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'transaction_detail_screen.dart';

class AccountDetailScreen extends StatefulWidget {
  final Account account;

  const AccountDetailScreen({
    Key? key,
    required this.account,
  }) : super(key: key);

  @override
  State<AccountDetailScreen> createState() => _AccountDetailScreenState();
}

class _AccountDetailScreenState extends State<AccountDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account.displayName),
      ),
      body: Column(
        children: [
          // Account card at the top
          _buildAccountHeader(),

          // Tab bar for transaction filtering
          _buildFilterTabs(),

          // Transactions list
          Expanded(
            child: _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountHeader() {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

    Color cardColor = Colors.blue;
    if (widget.account.color != null) {
      try {
        cardColor =
            Color(int.parse(widget.account.color!.replaceFirst('#', '0xFF')));
      } catch (e) {
        // Use default color if parsing fails
      }
    } else {
      // Default colors based on account type
      switch (widget.account.type) {
        case AccountType.bank:
          cardColor = Colors.blue;
          break;
        case AccountType.creditCard:
          cardColor = Colors.red;
          break;
        case AccountType.debitCard:
          cardColor = Colors.green;
          break;
        case AccountType.investment:
          cardColor = Colors.purple;
          break;
        case AccountType.insurance:
          cardColor = Colors.teal;
          break;
        case AccountType.other:
          cardColor = Colors.grey;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Account Type Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getAccountTypeIcon(),
              color: Colors.white,
              size: 32,
            ),
          ),

          const SizedBox(height: 16),

          // Account Name with Bank Name
          Text(
            widget.account.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Balance amount
          Text(
            currencyFormat.format(widget.account.balance),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          // Balance label
          Text(
            widget.account.balance >= 0
                ? 'Current Balance'
                : 'Outstanding Balance',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAccountTypeIcon() {
    switch (widget.account.type) {
      case AccountType.bank:
        return Icons.account_balance;
      case AccountType.creditCard:
        return Icons.credit_card;
      case AccountType.debitCard:
        return Icons.payment;
      case AccountType.investment:
        return Icons.show_chart;
      case AccountType.insurance:
        return Icons.health_and_safety;
      case AccountType.other:
        return Icons.account_balance_wallet;
    }
  }

  Widget _buildFilterTabs() {
    return DefaultTabController(
      length: 3,
      child: TabBar(
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Income'),
          Tab(text: 'Expenses'),
        ],
        indicatorColor: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildTransactionsList() {
    final transactionProvider = Provider.of<TransactionProvider>(context);
    final allTransactions = transactionProvider.transactions;

    // Filter transactions related to this account
    final accountTransactions = _getAccountTransactions(allTransactions);

    return DefaultTabController(
      length: 3,
      child: TabBarView(
        children: [
          // All transactions
          _buildTransactionListView(accountTransactions),

          // Income
          _buildTransactionListView(accountTransactions
              .where((t) => t.type == TransactionType.income)
              .toList()),

          // Expenses
          _buildTransactionListView(accountTransactions
              .where((t) => t.type == TransactionType.expense)
              .toList()),
        ],
      ),
    );
  }

  // Filter transactions that might be related to this account
  List<Transaction> _getAccountTransactions(List<Transaction> allTransactions) {
    final List<Transaction> result = [];

    for (final transaction in allTransactions) {
      // Check if transaction description contains bank name
      if (widget.account.bankName != null &&
          transaction.description
              .toUpperCase()
              .contains(widget.account.bankName!.toUpperCase())) {
        result.add(transaction);
        continue;
      }

      // Check if transaction tags contain account info
      if (widget.account.lastFourDigits != null &&
          transaction.tags
              .any((tag) => tag.contains(widget.account.lastFourDigits!))) {
        result.add(transaction);
        continue;
      }

      // For investment and insurance accounts, check category
      if (widget.account.type == AccountType.investment &&
          transaction.category.contains('Investment')) {
        result.add(transaction);
        continue;
      }

      if (widget.account.type == AccountType.insurance &&
          transaction.description.toUpperCase().contains('INSURANCE')) {
        result.add(transaction);
        continue;
      }
    }

    return result;
  }

  Widget _buildTransactionListView(List<Transaction> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Text('No transactions found for this account'),
      );
    }

    // Sort by date (most recent first)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        return _buildTransactionItem(transactions[index]);
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: transaction.type == TransactionType.income
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction.type == TransactionType.income
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: transaction.type == TransactionType.income
                    ? Colors.green
                    : Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.date),
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),

                  // Display tags if available
                  if (transaction.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: transaction.tags.map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue.shade100),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
            Text(
              currencyFormat.format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: transaction.type == TransactionType.income
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

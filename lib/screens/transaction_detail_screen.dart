import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../widgets/tag_manager.dart';
import '../providers/transaction_provider.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  State<TransactionDetailScreen> createState() =>
      _TransactionDetailScreenState();
}

class _TransactionDetailScreenState extends State<TransactionDetailScreen> {
  late Transaction _currentTransaction;

  @override
  void initState() {
    super.initState();
    _currentTransaction = widget.transaction;
  }

  void _refreshTransaction() {
    // Get the updated transaction from the provider
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final updatedTransaction = provider.transactions.firstWhere(
      (t) => t.id == _currentTransaction.id,
      orElse: () => _currentTransaction,
    );

    setState(() {
      _currentTransaction = updatedTransaction;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction summary card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _currentTransaction.type ==
                                    TransactionType.income
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _currentTransaction.type == TransactionType.income
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: _currentTransaction.type ==
                                    TransactionType.income
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _currentTransaction.type == TransactionType.income
                              ? 'Income'
                              : 'Expense',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      currencyFormat.format(_currentTransaction.amount),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color:
                            _currentTransaction.type == TransactionType.income
                                ? Colors.green
                                : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _detailRow('Description', _currentTransaction.description),
                    _detailRow('Category', _currentTransaction.category),
                    _detailRow(
                        'Date', dateFormat.format(_currentTransaction.date)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tag manager with refresh callback
            TagManager(
              transaction: _currentTransaction,
              onTagsUpdated: _refreshTransaction,
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

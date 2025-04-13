import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../providers/transaction_provider.dart';
import '../../../theme/app_theme.dart';
import '../../../models/transaction.dart';
import '../../../screens/transaction_detail_screen.dart'; // Corrected import path
import 'transaction_item.dart';

class TransactionList extends StatefulWidget {
  final String filter;
  final String timeFrame;
  final List<String> tags;
  final String searchQuery;

  const TransactionList({
    Key? key,
    required this.filter,
    required this.timeFrame,
    required this.tags,
    required this.searchQuery,
  }) : super(key: key);

  @override
  State<TransactionList> createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final filteredTransactions = _getFilteredTransactions(provider);

    if (filteredTransactions.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 24,
      ),
      itemCount: filteredTransactions.length,
      itemBuilder: (context, index) {
        final showDateHeader =
            _shouldShowDateHeader(index, filteredTransactions);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showDateHeader)
              _buildDateHeader(filteredTransactions[index].date),
            Container(
              margin: EdgeInsets.only(
                top: showDateHeader ? 8 : 0,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TransactionItem(
                transaction: filteredTransactions[index],
                onTap: () => _navigateToDetail(filteredTransactions[index]),
              ),
            ),
          ],
        );
      },
    );
  }

  List<Transaction> _getFilteredTransactions(TransactionProvider provider) {
    List<Transaction> result = List.from(provider.transactions);

    // Apply transaction type filter
    if (widget.filter == 'Income') {
      result = result.where((t) => t.type == TransactionType.income).toList();
    } else if (widget.filter == 'Expense') {
      result = result.where((t) => t.type == TransactionType.expense).toList();
    }

    // Apply time frame filter
    final now = DateTime.now();
    if (widget.timeFrame == 'Today') {
      result = result
          .where((t) =>
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day)
          .toList();
    } else if (widget.timeFrame == 'This Week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      result = result.where((t) => t.date.isAfter(startOfWeek)).toList();
    } else if (widget.timeFrame == 'This Month') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      result = result.where((t) => t.date.isAfter(startOfMonth)).toList();
    } else if (widget.timeFrame == 'Last 3 Months') {
      final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      result = result.where((t) => t.date.isAfter(threeMonthsAgo)).toList();
    }

    // Apply tag filters
    if (widget.tags.isNotEmpty) {
      result = result.where((transaction) {
        return widget.tags.any((tag) => transaction.tags.contains(tag));
      }).toList();
    }

    // Apply search query if available
    if (widget.searchQuery.isNotEmpty) {
      result = result.where((transaction) {
        return transaction.description
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase()) ||
            transaction.category
                .toLowerCase()
                .contains(widget.searchQuery.toLowerCase()) ||
            transaction.tags.any((tag) =>
                tag.toLowerCase().contains(widget.searchQuery.toLowerCase()));
      }).toList();
    }

    // Sort by date (most recent first)
    result.sort((a, b) => b.date.compareTo(a.date));

    return result;
  }

  bool _shouldShowDateHeader(int index, List<Transaction> transactions) {
    if (index == 0) return true;

    final currentDate = transactions[index].date;
    final previousDate = transactions[index - 1].date;

    return currentDate.year != previousDate.year ||
        currentDate.month != previousDate.month ||
        currentDate.day != previousDate.day;
  }

  Widget _buildDateHeader(DateTime date) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);

    String headerText;
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      headerText = 'Today';
    } else if (date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day) {
      headerText = 'Yesterday';
    } else {
      headerText = DateFormat('EEE, MMM d, yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16, left: 8),
      child: Text(
        headerText,
        style: TextStyle(
          color: AppTheme.textMedium,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 70,
            color: Colors.grey.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions found',
            style: TextStyle(
              color: AppTheme.textMedium,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try changing your filters',
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToDetail(Transaction transaction) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TransactionDetailScreen(transaction: transaction),
      ),
    ).then((_) {
      // Refresh the list when returning from details
      setState(() {});
    });
  }
}

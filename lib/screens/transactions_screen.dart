import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import 'transaction_detail_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _selectedFilter = 'All';
  String _selectedTimeFrame = 'All Time';
  List<String> _selectedTags = [];
  String _searchQuery = '';
  List<Transaction> _filteredTransactions = [];

  @override
  void initState() {
    super.initState();
    _applyFilters();
  }

  void _applyFilters() {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    List<Transaction> result = List.from(provider.transactions);

    // Apply transaction type filter
    if (_selectedFilter == 'Income') {
      result = result.where((t) => t.type == TransactionType.income).toList();
    } else if (_selectedFilter == 'Expense') {
      result = result.where((t) => t.type == TransactionType.expense).toList();
    }

    // Apply time frame filter
    final now = DateTime.now();
    if (_selectedTimeFrame == 'Today') {
      result = result
          .where((t) =>
              t.date.year == now.year &&
              t.date.month == now.month &&
              t.date.day == now.day)
          .toList();
    } else if (_selectedTimeFrame == 'This Week') {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      result = result.where((t) => t.date.isAfter(startOfWeek)).toList();
    } else if (_selectedTimeFrame == 'This Month') {
      final startOfMonth = DateTime(now.year, now.month, 1);
      result = result.where((t) => t.date.isAfter(startOfMonth)).toList();
    } else if (_selectedTimeFrame == 'Last 3 Months') {
      final threeMonthsAgo = DateTime(now.year, now.month - 3, now.day);
      result = result.where((t) => t.date.isAfter(threeMonthsAgo)).toList();
    }

    // Apply tag filters
    if (_selectedTags.isNotEmpty) {
      result = result.where((transaction) {
        return _selectedTags.any((tag) => transaction.tags.contains(tag));
      }).toList();
    }

    // Apply search query if available
    if (_searchQuery.isNotEmpty) {
      result = result.where((transaction) {
        return transaction.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            transaction.category
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()) ||
            transaction.tags.any((tag) =>
                tag.toLowerCase().contains(_searchQuery.toLowerCase()));
      }).toList();
    }

    // Sort by date (most recent first)
    result.sort((a, b) => b.date.compareTo(a.date));

    setState(() {
      _filteredTransactions = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final allTags = provider.allTags.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          // Tag filter button
          IconButton(
            icon: const Icon(Icons.label),
            onPressed: () {
              _showTagFilterBottomSheet(context, allTags);
            },
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchBar(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar (if active)
          if (_searchQuery.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Search: $_searchQuery',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                        _applyFilters();
                      });
                    },
                  ),
                ],
              ),
            ),

          _buildFilterBar(),

          // Selected tags bar
          if (_selectedTags.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtered by tags:',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _selectedTags.map((tag) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Chip(
                            label: Text(tag),
                            deleteIcon: const Icon(Icons.close, size: 16),
                            onDeleted: () {
                              setState(() {
                                _selectedTags.remove(tag);
                                _applyFilters();
                              });
                            },
                            backgroundColor: Colors.blue.shade100,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _filteredTransactions.isEmpty
                ? const Center(child: Text('No transactions found'))
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredTransactions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      return _buildTransactionItem(
                          _filteredTransactions[index]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade100,
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedFilter,
              items: const ['All', 'Income', 'Expense'],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedFilter = value;
                    _applyFilters();
                  });
                }
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildFilterDropdown(
              value: _selectedTimeFrame,
              items: const [
                'All Time',
                'Today',
                'This Week',
                'This Month',
                'Last 3 Months',
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTimeFrame = value;
                    _applyFilters();
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
      ),
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
        ).then((_) {
          // Refresh the list when returning from details
          _applyFilters();
        });
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

  void _showTagFilterBottomSheet(BuildContext context, List<String> allTags) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter by Tags',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          this.setState(() {
                            _selectedTags = [];
                            _applyFilters();
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Clear All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (allTags.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No tags available'),
                      ),
                    )
                  else
                    Expanded(
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: allTags.map((tag) {
                            final isSelected = _selectedTags.contains(tag);
                            return FilterChip(
                              label: Text(tag),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTags.add(tag);
                                  } else {
                                    _selectedTags.remove(tag);
                                  }
                                });

                                this.setState(() {
                                  _applyFilters();
                                });
                              },
                              selectedColor: Colors.blue.shade100,
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showSearchBar(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        String query = '';
        return AlertDialog(
          title: const Text('Search Transactions'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter description, category, or tag',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              query = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = query;
                  _applyFilters();
                });
                Navigator.pop(context);
              },
              child: const Text('Search'),
            ),
          ],
        );
      },
    );
  }
}

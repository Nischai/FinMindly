import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/transaction.dart';
import '../../providers/transaction_provider.dart';
import '../transaction_detail_screen.dart';

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
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        // Actions row
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Filter button
              FilledButton.tonalIcon(
                onPressed: () => _showFilterBottomSheet(context),
                icon: const Icon(Icons.filter_alt_outlined, size: 18),
                label: Text(
                    _selectedFilter == 'All' && _selectedTimeFrame == 'All Time'
                        ? 'Filter'
                        : 'Filtered'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Tag filter button
              FilledButton.tonalIcon(
                onPressed: () => _showTagFilterBottomSheet(context, allTags),
                icon: const Icon(Icons.label_outline, size: 18),
                label: Text(_selectedTags.isEmpty
                    ? 'Tags'
                    : 'Tags (${_selectedTags.length})'),
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const Spacer(),
              // Search button
              IconButton(
                onPressed: () => _showSearchBar(context),
                icon: const Icon(Icons.search),
                style: IconButton.styleFrom(
                  backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),

        // Search bar (if active)
        if (_searchQuery.isNotEmpty)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Row(
              children: [
                Icon(Icons.search,
                    color: colorScheme.onSurfaceVariant, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Search: $_searchQuery',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                      _applyFilters();
                    });
                  },
                  style: IconButton.styleFrom(
                    backgroundColor:
                        colorScheme.surfaceVariant.withOpacity(0.5),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(36, 36),
                  ),
                ),
              ],
            ),
          ),

        // Filter indicators
        if (_selectedFilter != 'All' || _selectedTimeFrame != 'All Time')
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_selectedFilter != 'All')
                  _buildFilterChip(
                    _selectedFilter,
                    onDeleted: () {
                      setState(() {
                        _selectedFilter = 'All';
                        _applyFilters();
                      });
                    },
                  ),
                if (_selectedTimeFrame != 'All Time')
                  _buildFilterChip(
                    _selectedTimeFrame,
                    onDeleted: () {
                      setState(() {
                        _selectedTimeFrame = 'All Time';
                        _applyFilters();
                      });
                    },
                  ),
              ],
            ),
          ),

        // Selected tags bar
        if (_selectedTags.isNotEmpty)
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tags:',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedTags = [];
                          _applyFilters();
                        });
                      },
                      child: const Text('Clear all'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedTags.map((tag) {
                    return _buildFilterChip(
                      tag,
                      onDeleted: () {
                        setState(() {
                          _selectedTags.remove(tag);
                          _applyFilters();
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        // Transactions list
        Expanded(
          child: _filteredTransactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.hourglass_empty,
                        size: 48,
                        color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No transactions found',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 16,
                        ),
                      ),
                      if (_searchQuery.isNotEmpty ||
                          _selectedTags.isNotEmpty ||
                          _selectedFilter != 'All' ||
                          _selectedTimeFrame != 'All Time')
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _selectedTags = [];
                              _selectedFilter = 'All';
                              _selectedTimeFrame = 'All Time';
                              _applyFilters();
                            });
                          },
                          child: const Text('Clear all filters'),
                        ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredTransactions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(_filteredTransactions[index]);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, {required VoidCallback onDeleted}) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      deleteIcon: const Icon(Icons.close, size: 16),
      onDeleted: onDeleted,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final colorScheme = Theme.of(context).colorScheme;

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
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    transaction.category,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateFormat.format(transaction.date),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
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
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 10,
                                color: colorScheme.onPrimaryContainer,
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

  void _showFilterBottomSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filter Transactions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Transaction Type',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'All', label: Text('All')),
                          ButtonSegment(value: 'Income', label: Text('Income')),
                          ButtonSegment(
                              value: 'Expense', label: Text('Expense')),
                        ],
                        selected: {_selectedFilter},
                        onSelectionChanged: (selection) {
                          setState(() {
                            _selectedFilter = selection.first;
                          });
                        },
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Time Period',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          'All Time',
                          'Today',
                          'This Week',
                          'This Month',
                          'Last 3 Months',
                        ].map((timeFrame) {
                          final isSelected = _selectedTimeFrame == timeFrame;
                          return ChoiceChip(
                            label: Text(timeFrame),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedTimeFrame = timeFrame;
                                });
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFilter = 'All';
                                  _selectedTimeFrame = 'All Time';
                                });
                              },
                              child: const Text('Reset'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Navigator.pop(context);
                                this.setState(() {
                                  _applyFilters();
                                });
                              },
                              child: const Text('Apply'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _showTagFilterBottomSheet(BuildContext context, List<String> allTags) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.5,
              minChildSize: 0.3,
              maxChildSize: 0.8,
              expand: false,
              builder: (context, scrollController) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Filter by Tags',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                // Clear locally
                                for (var tag in List.from(this._selectedTags)) {
                                  this._selectedTags.remove(tag);
                                }
                              });
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (allTags.isEmpty)
                        Expanded(
                          child: Center(
                            child: Text(
                              'No tags available',
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
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
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () {
                            Navigator.pop(context);
                            this.setState(() {
                              _applyFilters();
                            });
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
      },
    );
  }

  void _showSearchBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
            FilledButton(
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

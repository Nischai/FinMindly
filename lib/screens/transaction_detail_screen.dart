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
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Transaction header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _currentTransaction.type == TransactionType.income
                    ? colorScheme.tertiaryContainer
                    : colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  // Transaction type and icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color:
                              _currentTransaction.type == TransactionType.income
                                  ? colorScheme.tertiary.withOpacity(0.2)
                                  : colorScheme.error.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _currentTransaction.type == TransactionType.income
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          color:
                              _currentTransaction.type == TransactionType.income
                                  ? colorScheme.onTertiaryContainer
                                  : colorScheme.onErrorContainer,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _currentTransaction.type == TransactionType.income
                            ? 'Income'
                            : 'Expense',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              _currentTransaction.type == TransactionType.income
                                  ? colorScheme.onTertiaryContainer
                                  : colorScheme.onErrorContainer,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Amount
                  Text(
                    currencyFormat.format(_currentTransaction.amount),
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _currentTransaction.type == TransactionType.income
                          ? colorScheme.onTertiaryContainer
                          : colorScheme.onErrorContainer,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // Date
                  Text(
                    dateFormat.format(_currentTransaction.date),
                    style: TextStyle(
                      fontSize: 14,
                      color: _currentTransaction.type == TransactionType.income
                          ? colorScheme.onTertiaryContainer.withOpacity(0.8)
                          : colorScheme.onErrorContainer.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transaction details
            Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _detailRow(
                      context,
                      Icons.description,
                      'Description',
                      _currentTransaction.description,
                    ),
                    const Divider(height: 24),
                    _detailRow(
                      context,
                      Icons.category,
                      'Category',
                      _currentTransaction.category,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Tag manager with refresh callback
            TagManagerMD3(
              transaction: _currentTransaction,
              onTagsUpdated: _refreshTransaction,
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  context,
                  icon: Icons.edit,
                  label: 'Edit',
                  color: colorScheme.primary,
                  onTap: () {
                    // TODO: Implement edit
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Edit feature coming soon')),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.share,
                  label: 'Share',
                  color: colorScheme.tertiary,
                  onTap: () {
                    // TODO: Implement share
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share feature coming soon')),
                    );
                  },
                ),
                _buildActionButton(
                  context,
                  icon: Icons.delete,
                  label: 'Delete',
                  color: colorScheme.error,
                  onTap: () {
                    // TODO: Implement delete
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Delete feature coming soon')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Material Design 3 styled tag manager
class TagManagerMD3 extends StatefulWidget {
  final Transaction transaction;
  final Function onTagsUpdated;

  const TagManagerMD3({
    Key? key,
    required this.transaction,
    required this.onTagsUpdated,
  }) : super(key: key);

  @override
  State<TagManagerMD3> createState() => _TagManagerMD3State();
}

class _TagManagerMD3State extends State<TagManagerMD3> {
  final TextEditingController _tagController = TextEditingController();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _updateAvailableTags('');
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.trim().isEmpty) return;

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.addTagToTransaction(widget.transaction.id, tag.trim());
    _tagController.clear();

    _updateAvailableTags('');
    widget.onTagsUpdated();
  }

  void _removeTag(String tag) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.removeTagFromTransaction(widget.transaction.id, tag);

    _updateAvailableTags('');
    widget.onTagsUpdated();
  }

  void _updateAvailableTags(String query) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final allTags = provider.allTags.toList();

    setState(() {
      if (query.isEmpty) {
        _suggestions = allTags
            .where((tag) => !widget.transaction.tags.contains(tag))
            .toList();
      } else {
        _suggestions = allTags
            .where((tag) =>
                tag.toLowerCase().contains(query.toLowerCase()) &&
                !widget.transaction.tags.contains(tag))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tags',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            // Current tags
            if (widget.transaction.tags.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.transaction.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: colorScheme.primaryContainer,
                    labelStyle:
                        TextStyle(color: colorScheme.onPrimaryContainer),
                  );
                }).toList(),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'No tags yet. Add a tag to categorize this transaction.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // Add new tag
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: InputDecoration(
                      hintText: 'Add a tag...',
                      prefixIcon: const Icon(Icons.label_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: _updateAvailableTags,
                    onSubmitted: _addTag,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () => _addTag(_tagController.text),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primaryContainer,
                    foregroundColor: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),

            // Tag suggestions
            if (_suggestions.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tagController.text.isEmpty
                          ? 'Available tags:'
                          : 'Suggestions:',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _suggestions.map((tag) {
                        return ActionChip(
                          label: Text(tag),
                          onPressed: () => _addTag(tag),
                          backgroundColor: colorScheme.surface,
                          side: BorderSide(color: colorScheme.outlineVariant),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

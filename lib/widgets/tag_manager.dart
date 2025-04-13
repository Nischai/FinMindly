import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';

class TagManager extends StatefulWidget {
  final Transaction transaction;
  final Function onTagsUpdated;

  const TagManager({
    Key? key,
    required this.transaction,
    required this.onTagsUpdated,
  }) : super(key: key);

  @override
  State<TagManager> createState() => _TagManagerState();
}

class _TagManagerState extends State<TagManager> {
  final TextEditingController _tagController = TextEditingController();
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    // Initialize suggestions with all existing tags not already on this transaction
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

    // Update suggestions after adding a tag
    _updateAvailableTags('');

    // Notify parent that tags have been updated
    widget.onTagsUpdated();
  }

  void _removeTag(String tag) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.removeTagFromTransaction(widget.transaction.id, tag);

    // Update suggestions after removing a tag
    _updateAvailableTags('');

    // Notify parent that tags have been updated
    widget.onTagsUpdated();
  }

  void _updateAvailableTags(String query) {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    final allTags = provider.allTags.toList();

    setState(() {
      if (query.isEmpty) {
        // When no query, show all available tags not already on this transaction
        _suggestions = allTags
            .where((tag) => !widget.transaction.tags.contains(tag))
            .toList();
      } else {
        // When there's a query, filter available tags by the query
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tags',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),

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
                backgroundColor: Colors.blue.shade100,
              );
            }).toList(),
          ),

        const SizedBox(height: 16),

        // Add new tag
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _tagController,
                decoration: const InputDecoration(
                  hintText: 'Add a tag...',
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onChanged: _updateAvailableTags,
                onSubmitted: _addTag,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _addTag(_tagController.text),
            ),
          ],
        ),

        // Tag suggestions - always shown, with appropriate title based on whether there's a query
        if (_suggestions.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tagController.text.isEmpty
                      ? 'Available tags:'
                      : 'Suggestions:',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((tag) {
                    return GestureDetector(
                      onTap: () => _addTag(tag),
                      child: Chip(
                        label: Text(tag),
                        backgroundColor: Colors.grey.shade200,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

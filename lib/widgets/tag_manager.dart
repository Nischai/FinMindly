import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

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

class _TagManagerState extends State<TagManager>
    with SingleTickerProviderStateMixin {
  final TextEditingController _tagController = TextEditingController();
  List<String> _suggestions = [];
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    // Initialize suggestions with all existing tags not already on this transaction
    _updateAvailableTags('');
    _animationController.forward();
  }

  @override
  void dispose() {
    _tagController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _addTag(String tag) {
    if (tag.trim().isEmpty) return;

    final provider = Provider.of<TransactionProvider>(context, listen: false);
    provider.addTagToTransaction(widget.transaction.id, tag.trim());
    _tagController.clear();
    setState(() {
      _isTyping = false;
    });

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
        Row(
          children: [
            Icon(
              Icons.label_outline,
              color: AppTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Tags',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Current tags
        if (widget.transaction.tags.isNotEmpty)
          FadeTransition(
            opacity: _fadeAnimation,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.transaction.tags.map((tag) {
                return Chip(
                  label: Text(
                    tag,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  deleteIcon: const Icon(Icons.close, size: 16),
                  onDeleted: () => _removeTag(tag),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  deleteIconColor: AppTheme.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),

        // Add new tag
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.dividerColor),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagController,
                  decoration: InputDecoration(
                    hintText: 'Add a tag...',
                    hintStyle: TextStyle(color: AppTheme.textLight),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    prefixIcon: Icon(
                      Icons.add_circle_outline,
                      color: AppTheme.textLight,
                    ),
                  ),
                  style: TextStyle(
                    color: AppTheme.textDark,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _isTyping = value.isNotEmpty;
                    });
                    _updateAvailableTags(value);
                  },
                  onSubmitted: _addTag,
                ),
              ),
              if (_isTyping)
                IconButton(
                  icon: Icon(
                    Icons.send_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  onPressed: () => _addTag(_tagController.text),
                ),
            ],
          ),
        ),

        // Tag suggestions - shown only when there are suggestions
        if (_suggestions.isNotEmpty)
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      size: 16,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _tagController.text.isEmpty
                          ? 'Available tags'
                          : 'Suggestions',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _suggestions.map((tag) {
                    return GestureDetector(
                      onTap: () => _addTag(tag),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.dividerColor),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add,
                              size: 14,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              tag,
                              style: TextStyle(
                                color: AppTheme.textDark,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

        // Instructions
        if (widget.transaction.tags.isEmpty && _suggestions.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.textLight,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tags help you categorize and filter your transactions more effectively',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

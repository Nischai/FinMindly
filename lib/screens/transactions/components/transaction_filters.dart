import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TransactionFilters extends StatelessWidget {
  final String selectedFilter;
  final String selectedTimeFrame;
  final Function(String) onFilterChanged;
  final Function(String) onTimeFrameChanged;

  const TransactionFilters({
    Key? key,
    required this.selectedFilter,
    required this.selectedTimeFrame,
    required this.onFilterChanged,
    required this.onTimeFrameChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              value: selectedFilter,
              items: const ['All', 'Income', 'Expense'],
              onChanged: (value) {
                if (value != null) {
                  onFilterChanged(value);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildFilterDropdown(
              value: selectedTimeFrame,
              items: const [
                'All Time',
                'Today',
                'This Week',
                'This Month',
                'Last 3 Months',
              ],
              onChanged: (value) {
                if (value != null) {
                  onTimeFrameChanged(value);
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: DropdownButton<String>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: TextStyle(
                color: AppTheme.textDark,
                fontSize: 14,
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        isExpanded: true,
        underline: const SizedBox(),
        icon: Icon(Icons.arrow_drop_down, color: AppTheme.textMedium),
        dropdownColor: AppTheme.surfaceLight,
      ),
    );
  }
}

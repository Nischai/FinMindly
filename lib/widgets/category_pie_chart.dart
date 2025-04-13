import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

class CategoryPieChart extends StatefulWidget {
  final TransactionProvider provider;

  const CategoryPieChart({
    Key? key,
    required this.provider,
  }) : super(key: key);

  @override
  State<CategoryPieChart> createState() => _CategoryPieChartState();
}

class _CategoryPieChartState extends State<CategoryPieChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoryExpenses = widget.provider.getExpensesByCategory();
    final totalExpenses = widget.provider.getTotalExpenses();

    // Generate sections for pie chart
    final sections = <PieChartSectionData>[];
    final legends = <Widget>[];

    int colorIndex = 0;

    for (final entry in categoryExpenses.entries) {
      if (totalExpenses > 0) {
        final percentage = (entry.value / totalExpenses) * 100;
        final color = AppTheme
            .categoryColors[colorIndex % AppTheme.categoryColors.length];
        colorIndex++;

        // Add pie section
        sections.add(
          PieChartSectionData(
            value: entry.value,
            title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
            color: color,
            radius: _touchedIndex == colorIndex - 1 ? 110 : 100,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            badgeWidget: percentage < 5
                ? _Badge(
                    size: 16,
                    borderColor: color,
                  )
                : null,
            badgePositionPercentageOffset: 1.1,
          ),
        );

        // Add legend item
        legends.add(
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: _buildLegendItem(
              context,
              color: color,
              label: entry.key,
              amount: NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                  .format(entry.value),
              percentage: percentage,
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        sections.isEmpty
            ? _buildEmptyState()
            : AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return SizedBox(
                    height: 240,
                    child: PieChart(
                      PieChartData(
                        sections: sections.map((section) {
                          return PieChartSectionData(
                            value: section.value,
                            title: section.title,
                            color: section.color,
                            radius: section.radius * _animation.value,
                            titleStyle: section.titleStyle,
                            badgeWidget: section.badgeWidget,
                            badgePositionPercentageOffset:
                                section.badgePositionPercentageOffset,
                          );
                        }).toList(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        pieTouchData: PieTouchData(
                          touchCallback:
                              (FlTouchEvent event, pieTouchResponse) {
                            setState(() {
                              if (!event.isInterestedForInteractions ||
                                  pieTouchResponse == null ||
                                  pieTouchResponse.touchedSection == null) {
                                _touchedIndex = -1;
                                return;
                              }
                              _touchedIndex = pieTouchResponse
                                  .touchedSection!.touchedSectionIndex;
                            });
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
        const SizedBox(height: 24),
        Column(
          children: legends,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SizedBox(
      height: 240,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: Colors.grey.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No expense data available',
              style: TextStyle(
                color: AppTheme.textMedium,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Transaction data will appear here once available',
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(
    BuildContext context, {
    required Color color,
    required String label,
    required String amount,
    required double percentage,
  }) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '${percentage.toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          amount,
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// Badge widget for small pie sections
class _Badge extends StatelessWidget {
  final double size;
  final Color borderColor;

  const _Badge({
    Key? key,
    required this.size,
    required this.borderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 3,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../models/transaction.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  String _period = 'Week'; // 'Week', 'Month', 'Year'

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Period selector
          _buildPeriodSelector(context),
          const SizedBox(height: 24),

          // Daily/Weekly/Monthly Bar Chart
          _buildBarChart(context),
          const SizedBox(height: 24),

          // Expense Categories Pie Chart
          _buildCategoryChart(context),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'Week',
              label: Text('Week'),
              icon: Icon(Icons.calendar_view_week),
            ),
            ButtonSegment(
              value: 'Month',
              label: Text('Month'),
              icon: Icon(Icons.calendar_month),
            ),
            ButtonSegment(
              value: 'Year',
              label: Text('Year'),
              icon: Icon(Icons.calendar_today),
            ),
          ],
          selected: {_period},
          onSelectionChanged: (selection) {
            setState(() {
              _period = selection.first;
            });
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return colorScheme.primaryContainer;
              }
              return null;
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    // Get data based on selected period
    Map<String, double> expensesData;
    Map<String, double> incomeData;

    int daysToInclude = 7;
    if (_period == 'Month') {
      daysToInclude = 30;
    } else if (_period == 'Year') {
      daysToInclude = 365;
    }

    expensesData = provider.getDailyExpenses(daysBack: daysToInclude);
    incomeData = provider.getDailyIncome(daysBack: daysToInclude);

    // Only show the last 7 days for Week, or last 12 months for Year
    final keys = expensesData.keys.toList();
    if (_period == 'Week') {
      keys.sort(); // Sort by date
      if (keys.length > 7) {
        final recentKeys = keys.sublist(keys.length - 7);
        expensesData = {for (var key in recentKeys) key: expensesData[key]!};
        incomeData = {for (var key in recentKeys) key: incomeData[key]!};
      }
    }

    // Convert data for bar chart
    final List<String> xLabels = expensesData.keys.toList();
    xLabels.sort(); // Sort by date

    // Find max value for Y axis scale
    double maxY = 0;
    for (int i = 0; i < xLabels.length; i++) {
      final key = xLabels[i];
      final expenseValue = expensesData[key] ?? 0;
      final incomeValue = incomeData[key] ?? 0;
      maxY = [maxY, expenseValue, incomeValue].reduce((a, b) => a > b ? a : b);
    }

    // Add 10% padding to max value
    maxY = maxY * 1.1;

    // Format currency for Y axis
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Financial Activity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY,
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value % (maxY / 4).round() != 0) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              currencyFormat.format(value),
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 60,
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value >= xLabels.length) {
                            return const SizedBox.shrink();
                          }

                          // Show abbreviated labels for readability
                          String label = xLabels[value.toInt()];

                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: colorScheme.onSurfaceVariant,
                                fontSize: 10,
                              ),
                            ),
                          );
                        },
                        reservedSize: 30,
                      ),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxY / 4,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: colorScheme.outlineVariant.withOpacity(0.3),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                  groupsSpace: 6,
                  barGroups: List.generate(xLabels.length, (index) {
                    final key = xLabels[index];
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        // Income bar
                        BarChartRodData(
                          toY: incomeData[key] ?? 0,
                          color: colorScheme.tertiary,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                        // Expense bar
                        BarChartRodData(
                          toY: expensesData[key] ?? 0,
                          color: colorScheme.error,
                          width: 12,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(4),
                            topRight: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _chartLegendItem(context, Colors.green, 'Income'),
                const SizedBox(width: 24),
                _chartLegendItem(context, Colors.red, 'Expenses'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartLegendItem(BuildContext context, Color color, String label) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChart(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categoryExpenses = provider.getExpensesByCategory();
    final colorScheme = Theme.of(context).colorScheme;

    // Generate colors for categories
    final List<Color> colors = [
      colorScheme.primary,
      colorScheme.error,
      colorScheme.tertiary,
      colorScheme.secondary,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
      Colors.brown,
      Colors.cyan,
    ];

    final List<PieChartSectionData> sections = [];
    int colorIndex = 0;

    final totalExpenses = provider.getTotalExpenses();

    for (final entry in categoryExpenses.entries) {
      if (totalExpenses > 0) {
        final percentage = (entry.value / totalExpenses) * 100;
        sections.add(
          PieChartSectionData(
            value: entry.value,
            title: percentage >= 5 ? '${percentage.toStringAsFixed(1)}%' : '',
            color: colors[colorIndex % colors.length],
            radius: 120,
            titleStyle: TextStyle(
              color: colorScheme.surface,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
            badgeWidget: percentage < 5
                ? null
                : null, // Could add badge for small sections
            badgePositionPercentageOffset: 1.2,
          ),
        );
        colorIndex++;
      }
    }

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Categories',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 250,
              child: sections.isEmpty
                  ? Center(
                      child: Text(
                        'No expense data available',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : PieChart(
                      PieChartData(
                        sections: sections,
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categoryExpenses.entries.map((entry) {
                final index = categoryExpenses.keys.toList().indexOf(entry.key);
                return _categoryLegendItem(
                  context,
                  colors[index % colors.length],
                  entry.key,
                  NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                      .format(entry.value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryLegendItem(
    BuildContext context,
    Color color,
    String label,
    String amount,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '$label: $amount',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

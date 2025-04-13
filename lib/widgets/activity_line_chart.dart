import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../theme/app_theme.dart';

class ActivityLineChart extends StatefulWidget {
  final TransactionProvider provider;
  final int daysBack;

  const ActivityLineChart({
    Key? key,
    required this.provider,
    required this.daysBack,
  }) : super(key: key);

  @override
  State<ActivityLineChart> createState() => _ActivityLineChartState();
}

class _ActivityLineChartState extends State<ActivityLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubicEmphasized,
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
    final dailyExpenses =
        widget.provider.getDailyExpenses(daysBack: widget.daysBack);
    final dailyIncome =
        widget.provider.getDailyIncome(daysBack: widget.daysBack);

    // Find max value for y-axis scaling
    double maxY = 0;
    dailyIncome.values.forEach((value) {
      if (value > maxY) maxY = value;
    });
    dailyExpenses.values.forEach((value) {
      if (value > maxY) maxY = value;
    });

    // Add 10% padding to max value
    maxY *= 1.1;

    // Get x-axis date labels
    final dateLabels = dailyExpenses.keys.toList();

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: 240,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppTheme.dividerColor,
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < dateLabels.length) {
                        // Show fewer labels when we have more days
                        if (widget.daysBack > 30 && value.toInt() % 5 != 0) {
                          return const SizedBox.shrink();
                        }
                        if (widget.daysBack > 7 &&
                            widget.daysBack <= 30 &&
                            value.toInt() % 3 != 0) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            dateLabels[value.toInt()],
                            style: TextStyle(
                              fontSize: 10,
                              color: AppTheme.textLight,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value == 0) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          NumberFormat.compact().format(value),
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    },
                    reservedSize: 30,
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(
                show: false,
              ),
              minX: 0,
              maxX: (dateLabels.length - 1).toDouble(),
              minY: 0,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.white.withOpacity(0.8),
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                    return touchedSpots.map((spot) {
                      final isIncome = spot.barIndex == 0;
                      final formattedValue =
                          NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                              .format(spot.y);

                      return LineTooltipItem(
                        '${isIncome ? 'Income' : 'Expense'}: $formattedValue',
                        TextStyle(
                          color: isIncome
                              ? AppTheme.incomeColor
                              : AppTheme.expenseColor,
                          fontWeight: FontWeight.bold,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: [
                // Income line
                LineChartBarData(
                  spots: dailyIncome.entries.map((entry) {
                    return FlSpot(
                      dailyIncome.keys.toList().indexOf(entry.key).toDouble(),
                      entry.value * _animation.value,
                    );
                  }).toList(),
                  isCurved: true,
                  color: AppTheme.incomeColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.incomeColor.withOpacity(0.1),
                  ),
                ),
                // Expenses line
                LineChartBarData(
                  spots: dailyExpenses.entries.map((entry) {
                    return FlSpot(
                      dailyExpenses.keys.toList().indexOf(entry.key).toDouble(),
                      entry.value * _animation.value,
                    );
                  }).toList(),
                  isCurved: true,
                  color: AppTheme.expenseColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: false,
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppTheme.expenseColor.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

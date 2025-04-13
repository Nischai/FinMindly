import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/transaction_provider.dart';
import '../services/sms_service.dart';
import '../models/transaction.dart';
import 'transactions_screen.dart';
import 'transaction_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    await provider.loadTransactions();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });

    // Reload SMS messages
    final smsService = SMSService();
    await smsService.loadMessages(context);

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FinMind Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildDailyChart(),
                    const SizedBox(height: 24),
                    _buildCategoryChart(),
                    const SizedBox(height: 24),
                    _buildRecentTransactions(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TransactionsScreen(),
            ),
          );
        },
        child: const Icon(Icons.list),
      ),
    );
  }

  Widget _buildSummaryCards() {
    final provider = Provider.of<TransactionProvider>(context);
    final totalIncome = provider.getTotalIncome();
    final totalExpenses = provider.getTotalExpenses();
    final balance = totalIncome - totalExpenses;

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return Row(
      children: [
        Expanded(
          child: _summaryCard(
            title: 'Income',
            amount: currencyFormat.format(totalIncome),
            color: Colors.green,
            icon: Icons.arrow_upward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: 'Expenses',
            amount: currencyFormat.format(totalExpenses),
            color: Colors.red,
            icon: Icons.arrow_downward,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _summaryCard(
            title: 'Balance',
            amount: currencyFormat.format(balance),
            color: balance >= 0 ? Colors.blue : Colors.orange,
            icon: balance >= 0 ? Icons.account_balance_wallet : Icons.warning,
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 4),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              amount,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyChart() {
    final provider = Provider.of<TransactionProvider>(context);
    final dailyExpenses = provider.getDailyExpenses();
    final dailyIncome = provider.getDailyIncome();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Financial Activity',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final days = dailyExpenses.keys.toList();
                          if (value.toInt() >= 0 &&
                              value.toInt() < days.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Text(
                                days[value.toInt()],
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                        reservedSize: 30,
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  minX: 0,
                  maxX: dailyExpenses.length.toDouble() - 1,
                  lineBarsData: [
                    // Expenses line
                    LineChartBarData(
                      spots: dailyExpenses.entries
                          .map((entry) => FlSpot(
                                dailyExpenses.keys
                                    .toList()
                                    .indexOf(entry.key)
                                    .toDouble(),
                                entry.value,
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                    // Income line
                    LineChartBarData(
                      spots: dailyIncome.entries
                          .map((entry) => FlSpot(
                                dailyIncome.keys
                                    .toList()
                                    .indexOf(entry.key)
                                    .toDouble(),
                                entry.value,
                              ))
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _chartLegendItem(color: Colors.green, label: 'Income'),
                const SizedBox(width: 24),
                _chartLegendItem(color: Colors.red, label: 'Expenses'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartLegendItem({required Color color, required String label}) {
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
        Text(label),
      ],
    );
  }

  Widget _buildCategoryChart() {
    final provider = Provider.of<TransactionProvider>(context);
    final categoryExpenses = provider.getExpensesByCategory();

    // Generate colors for categories
    final List<Color> colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
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
            title: '${percentage.toStringAsFixed(1)}%',
            color: colors[colorIndex % colors.length],
            radius: 100,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        );
        colorIndex++;
      }
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Categories',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: sections.isEmpty
                  ? const Center(child: Text('No expense data available'))
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
                  color: colors[index % colors.length],
                  label: entry.key,
                  amount: NumberFormat.currency(symbol: '₹', decimalDigits: 0)
                      .format(entry.value),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryLegendItem({
    required Color color,
    required String label,
    required String amount,
  }) {
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
        Text('$label: $amount', style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildRecentTransactions() {
    final provider = Provider.of<TransactionProvider>(context);
    final transactions = provider.transactions;

    // Sort by date (most recent first) and take only the last 5
    final recentTransactions = List.from(transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    final displayTransactions = recentTransactions.take(5).toList();

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const TransactionsScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (displayTransactions.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: Text('No transactions yet')),
              )
            else
              ...displayTransactions
                  .map((transaction) => _transactionListItem(transaction)),
          ],
        ),
      ),
    );
  }

  Widget _transactionListItem(Transaction transaction) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final dateFormat = DateFormat('dd MMM, yyyy');

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TransactionDetailScreen(transaction: transaction),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
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
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.description,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${transaction.category} • ${dateFormat.format(transaction.date)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  // Display tags if available
                  if (transaction.tags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(Icons.label,
                              size: 12, color: Colors.blue.shade300),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              transaction.tags.join(', '),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Text(
              currencyFormat.format(transaction.amount),
              style: TextStyle(
                fontWeight: FontWeight.bold,
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../providers/account_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _currency = '₹ (INR)';
  String _language = 'English';

  final List<String> _currencies = [
    '₹ (INR)',
    '\$ (USD)',
    '€ (EUR)',
    '£ (GBP)'
  ];
  final List<String> _languages = [
    'English',
    'Hindi',
    'Telugu',
    'Tamil',
    'Malayalam'
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return ListView(
      children: [
        _buildSectionHeader('Appearance'),
        SwitchListTile(
          title: const Text('Dark Mode'),
          subtitle: const Text('Switch between light and dark theme'),
          value: themeProvider.isDarkMode,
          onChanged: (value) {
            themeProvider.setDarkMode(value);
          },
          secondary: Icon(
            themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            color:
                themeProvider.isDarkMode ? colorScheme.primary : Colors.amber,
          ),
        ),
        _buildDivider(),
        _buildSectionHeader('Notifications'),
        SwitchListTile(
          title: const Text('Transaction Alerts'),
          subtitle: const Text('Get notified about new transactions'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            // TODO: Implement notifications
          },
          secondary: Icon(
            _notificationsEnabled
                ? Icons.notifications_active
                : Icons.notifications_off,
            color: _notificationsEnabled
                ? colorScheme.primary
                : colorScheme.outline,
          ),
        ),
        _buildDivider(),
        _buildSectionHeader('Regional Settings'),
        ListTile(
          title: const Text('Currency'),
          subtitle: Text(_currency),
          leading: const Icon(Icons.currency_exchange),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showCurrencyPicker(),
        ),
        ListTile(
          title: const Text('Language'),
          subtitle: Text(_language),
          leading: const Icon(Icons.language),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguagePicker(),
        ),
        _buildDivider(),
        _buildSectionHeader('Data Management'),
        ListTile(
          title: const Text('Export Transactions'),
          subtitle: const Text('Save your transaction data as CSV'),
          leading: const Icon(Icons.download),
          onTap: () {
            // TODO: Implement export
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Export feature coming soon')),
            );
          },
        ),
        ListTile(
          title: const Text('Clear Data'),
          subtitle: const Text('Delete all transaction and account data'),
          leading: Icon(Icons.delete_forever, color: colorScheme.error),
          onTap: () => _showClearDataDialog(),
        ),
        _buildDivider(),
        _buildSectionHeader('About'),
        ListTile(
          title: const Text('Privacy Policy'),
          subtitle: const Text('View our privacy policy'),
          leading: const Icon(Icons.privacy_tip),
          onTap: () {
            // TODO: Implement privacy policy
          },
        ),
        ListTile(
          title: const Text('About FinMindly'),
          subtitle: const Text('Version 1.0.0'),
          leading: const Icon(Icons.info),
          onTap: () {
            _showAboutDialog();
          },
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
    );
  }

  void _showCurrencyPicker() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: _currencies.map((currency) {
            return ListTile(
              title: Text(currency),
              trailing: currency == _currency
                  ? Icon(Icons.check, color: colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _currency = currency;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showLanguagePicker() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: _languages.map((language) {
            return ListTile(
              title: Text(language),
              trailing: language == _language
                  ? Icon(Icons.check, color: colorScheme.primary)
                  : null,
              onTap: () {
                setState(() {
                  _language = language;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showClearDataDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear All Data'),
          content: const Text(
              'This will erase all transactions and accounts. This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                // Clear all data
                final transactionProvider =
                    Provider.of<TransactionProvider>(context, listen: false);
                final accountProvider =
                    Provider.of<AccountProvider>(context, listen: false);

                transactionProvider.setTransactions([]);
                accountProvider.clearAccounts();

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared')),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
              ),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('About FinMindly'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'FinMindly is a personal finance tracking app that automatically analyzes your bank SMS messages to track your transactions and provide insights into your financial activity.',
              ),
              const SizedBox(height: 16),
              Text(
                'Version: 1.0.0',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 8),
              Text(
                'Copyright © 2023',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}

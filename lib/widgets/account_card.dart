import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/account.dart';

class AccountCard extends StatelessWidget {
  final Account account;
  final VoidCallback onTap;

  const AccountCard({
    Key? key,
    required this.account,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);
    final colorScheme = Theme.of(context).colorScheme;

    // Card color based on account type
    Color cardColor;
    switch (account.type) {
      case AccountType.bank:
        cardColor = colorScheme.primaryContainer;
        break;
      case AccountType.creditCard:
        cardColor = colorScheme.errorContainer;
        break;
      case AccountType.debitCard:
        cardColor = colorScheme.secondaryContainer;
        break;
      case AccountType.investment:
        cardColor = colorScheme.tertiaryContainer;
        break;
      case AccountType.insurance:
        cardColor = Colors.teal.withOpacity(0.2);
        break;
      case AccountType.other:
        cardColor = Colors.grey.withOpacity(0.2);
        break;
    }

    // Text color based on account type
    Color textColor;
    switch (account.type) {
      case AccountType.bank:
        textColor = colorScheme.onPrimaryContainer;
        break;
      case AccountType.creditCard:
        textColor = colorScheme.onErrorContainer;
        break;
      case AccountType.debitCard:
        textColor = colorScheme.onSecondaryContainer;
        break;
      case AccountType.investment:
        textColor = colorScheme.onTertiaryContainer;
        break;
      case AccountType.insurance:
      case AccountType.other:
        textColor = colorScheme.onSurface;
        break;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      color: cardColor,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top section with bank name and icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bank name
                  if (account.bankName != null)
                    Text(
                      account.bankName!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  // Account type icon
                  _buildAccountTypeIcon(textColor),
                ],
              ),

              const Spacer(),

              // Card number if available
              if (account.lastFourDigits != null)
                Text(
                  '•••• •••• •••• ${account.lastFourDigits}',
                  style: TextStyle(
                    color: textColor.withOpacity(0.8),
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),

              const SizedBox(height: 12),

              // Account name
              Text(
                account.name,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              // Balance amount
              Text(
                currencyFormat.format(account.balance),
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountTypeIcon(Color iconColor) {
    IconData iconData;

    switch (account.type) {
      case AccountType.bank:
        iconData = Icons.account_balance_outlined;
        break;
      case AccountType.creditCard:
        iconData = Icons.credit_card_outlined;
        break;
      case AccountType.debitCard:
        iconData = Icons.payment_outlined;
        break;
      case AccountType.investment:
        iconData = Icons.trending_up_outlined;
        break;
      case AccountType.insurance:
        iconData = Icons.health_and_safety_outlined;
        break;
      case AccountType.other:
        iconData = Icons.account_balance_wallet_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }
}

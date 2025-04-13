import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class TransactionSearch extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const TransactionSearch({
    Key? key,
    required this.controller,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Search transactions...',
        hintStyle: TextStyle(color: AppTheme.textLight),
        border: InputBorder.none,
      ),
      style: TextStyle(color: AppTheme.textDark),
      autofocus: true,
      onChanged: onChanged,
    );
  }
}

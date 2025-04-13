# FinMindly - Project Summary

## Overview
FinMindly is a mobile finance tracking application that automatically analyzes bank SMS messages to track and categorize transactions. The app provides users with insights into their spending habits, account balances, and financial activities through a modern, user-friendly interface built with Flutter and Material Design 3.

## Project Development Journey

### Initial Implementation
- Created the base application structure with SMS permission handling
- Implemented SMS parsing logic to extract transaction details
- Built transaction model and provider for state management
- Created basic UI screens for home, transactions, and transaction details

### Feature Expansion
- Added transaction categorization based on keywords
- Implemented tag management system for transactions
- Created statistics visualization with charts
- Added filtering and search capabilities for transactions

### Design Evolution
- Updated UI from basic Material Design to Material Design 3
- Replaced line charts with bar charts for better visualization
- Redesigned card layouts for better visual hierarchy
- Implemented dark mode as the default theme

### Account Management
- Added account model to represent different financial accounts
- Implemented account detection logic from transaction data
- Created account cards with visual identifiers for different account types
- Displayed account balances based on associated transactions

### Navigation & Structure
- Implemented bottom navigation with Home, Stats, Transactions, and Settings tabs
- Created consistent app bar across all screens
- Added proper navigation between screens
- Ensured bottom navigation stays visible throughout the app

## Key Features

### Transaction Management
- Automatic parsing of bank SMS messages to extract transaction details
- Intelligent categorization of transactions (income/expense)
- Ability to tag, search, and filter transactions
- Detailed transaction view with editing capabilities

### Account Management
- Automatic detection of accounts from transaction data
- Support for multiple account types (bank accounts, credit cards, debit cards, investments, insurance)
- Visual representation of accounts with balances in a horizontal scrollable list
- Display of last 4 digits of card/account numbers for easy identification

### Financial Insights
- Bar charts showing income vs. expenses over different time periods
- Pie chart visualization of spending by category 
- Summary cards showing total income, expenses, and balance
- Time-based filtering (day, week, month, year)

### User Experience
- Modern Material Design 3 UI implementation
- Dark mode enabled by default with toggle in settings
- Bottom navigation for easy access to home, stats, transactions, and settings
- Clean, intuitive interface with consistent design patterns

### Settings & Customization
- Theme toggle (light/dark mode)
- Regional settings (currency, language)
- Data management (export, clear data)
- Notification preferences

## Technical Implementation

### Architecture
- Provider pattern for state management
- Clean separation of UI, business logic, and data layers
- Modular design for easy maintainability and extensibility

### Key Files
- `lib/main.dart`: Application entry point and theme configuration
- `lib/models/transaction.dart`: Transaction data model
- `lib/models/account.dart`: Account data model
- `lib/providers/transaction_provider.dart`: Transaction state management
- `lib/providers/account_provider.dart`: Account state management
- `lib/providers/theme_provider.dart`: Theme state management
- `lib/services/sms_service.dart`: SMS parsing and transaction extraction
- `lib/screens/home_screen.dart`: Main dashboard
- `lib/screens/stats_screen.dart`: Financial statistics and charts
- `lib/screens/transactions_screen.dart`: Transaction listing and filtering
- `lib/screens/settings_screen.dart`: App settings
- `lib/screens/transaction_detail_screen.dart`: Transaction details
- `lib/widgets/account_card.dart`: Account UI component
- `lib/widgets/tag_manager.dart`: Tag management UI component

### Key Libraries & Dependencies
- Flutter for cross-platform UI development
- Provider for state management
- Shared Preferences for local storage
- FL Chart for data visualization
- Intl for localization and formatting
- Permission Handler for SMS access permissions

## Feature Details

### SMS Parsing Logic
The app analyzes bank SMS messages to extract:
- Transaction type (income/expense)
- Amount
- Date and time
- Description/merchant
- Bank or card information
- Auto-categorization based on keywords

### Account Detection
The system identifies accounts based on:
- Bank name mentions in transaction descriptions
- Card numbers (last 4 digits)
- Transaction patterns
- Associated banking institutions

### Statistics and Insights
The app provides visual insights through:
- Daily/weekly/monthly expense tracking
- Category-based spending analysis
- Income vs expense comparisons
- Balance tracking across accounts

### UI/UX Implementation
- Used Material Design 3 color system for consistent theming
- Implemented proper elevation hierarchy for cards and surfaces
- Used appropriate spacing and typography scale
- Designed intuitive navigation patterns
- Ensured visual consistency across all screens

## Design Philosophy
The application follows Material Design 3 guidelines with a focus on:
- Clean, minimalist interfaces
- Consistent visual hierarchy
- Intuitive navigation
- Proper spacing and typography
- Accessible color schemes in both light and dark modes

## Future Enhancements
- Additional visualization options for financial data
- Budget tracking and goal setting
- Cloud backup and synchronization
- Export options for financial reports
- Enhanced account management features
- More detailed financial insights and trends analysis

FinMindly aims to simplify personal finance tracking by automating the tedious process of recording transactions while providing meaningful insights into spending patterns and financial health.
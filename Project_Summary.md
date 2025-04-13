# FinMind - Financial Transaction Tracker

## Project Overview

FinMind is a Flutter mobile application that automatically tracks financial transactions by analyzing bank SMS messages. The app reads bank SMS notifications, extracts transaction details, and provides insightful financial statistics and visualizations to help users monitor their spending and income patterns.

## Key Features

1. **Automatic SMS Transaction Parsing**
   - Requests SMS permissions when first launched
   - Reads and analyzes bank transaction messages
   - Extracts transaction amount, date, description, and type
   - Supports multiple Indian bank message formats

2. **Smart Transaction Categorization**
   - Automatically categorizes transactions into predefined categories
   - Identifies transaction types (income/expense)
   - Custom tagging system for personalized organization

3. **Financial Dashboard**
   - Summary cards showing income, expenses, and balance
   - Daily financial activity charts comparing income vs. expenses
   - Category-wise expense breakdown with pie chart visualization
   - Recent transactions list with quick access to details

4. **Transaction Management**
   - Complete transaction history with filtering options
   - Search functionality across descriptions, categories, and tags
   - Detailed transaction view with all information
   - Custom tagging system for personalized organization

5. **Advanced Filtering System**
   - Filter by transaction type (income/expense)
   - Filter by time frame (today, this week, this month, etc.)
   - Filter by custom tags
   - Search by keywords across all transaction data

6. **Tag Management System**
   - Add custom tags to transactions for better organization
   - View and remove tags from transactions
   - Filter transactions by tags
   - Tag suggestions based on existing tags
   - Real-time UI updates when modifying tags

## Technical Implementation

### Architecture

The application follows a structured architecture with clear separation of concerns:

- **Models**: Define data structures for transactions and other entities
- **Services**: Handle system interactions like SMS reading
- **Providers**: Manage application state and data persistence
- **Screens**: Handle user interface and interaction
- **Widgets**: Reusable UI components

### Key Components

1. **SMS Service**
   - Reads SMS messages using the flutter_sms_inbox package
   - Parses transaction details using regular expressions
   - Categorizes transactions based on keywords
   - Handles SMS permission requests

2. **Transaction Provider**
   - Manages transaction data using Provider pattern
   - Provides methods for transaction filtering and statistics
   - Handles data persistence using SharedPreferences
   - Manages tags and tag-related operations

3. **UI Components**
   - Data visualization using fl_chart for line and pie charts
   - Material Design components with custom styling
   - Responsive layouts for different screen sizes
   - Interactive filtering and search interface

### Data Flow

1. User grants SMS permission on first launch
2. App reads SMS messages and extracts transaction data
3. Transactions are stored locally using SharedPreferences
4. UI components observe the TransactionProvider for changes
5. When data changes (e.g., adding a tag), UI updates automatically

## Project Structure

```
lib/
├── main.dart            # App entry point with permission handling
├── models/
│   └── transaction.dart # Transaction data model
├── providers/
│   └── transaction_provider.dart # State management
├── screens/
│   ├── home_screen.dart # Dashboard with statistics
│   ├── transaction_detail_screen.dart # Transaction details
│   └── transactions_screen.dart # Transaction list and filtering
├── services/
│   └── sms_service.dart # SMS reading and parsing
└── widgets/
    └── tag_manager.dart # Tag management component
```

## Dependencies

- **flutter_sms_inbox**: For reading SMS messages
- **permission_handler**: For managing app permissions
- **provider**: For state management
- **fl_chart**: For data visualization
- **shared_preferences**: For local data persistence
- **intl**: For date and number formatting

## Challenges and Solutions

1. **SMS Format Variability**
   - Challenge: Different banks use different SMS formats
   - Solution: Implemented flexible parsing with multiple pattern matching

2. **Permission Handling**
   - Challenge: SMS permissions are critical but can be denied
   - Solution: Clear permission request flow with explanations

3. **Transaction Categorization**
   - Challenge: Accurately categorizing diverse transactions
   - Solution: Keyword-based categorization with fallback options

4. **Real-time UI Updates**
   - Challenge: Keeping UI in sync with data changes
   - Solution: Implemented callbacks and state management with Provider

5. **Tag Management**
   - Challenge: Creating an intuitive tagging system
   - Solution: Built suggestion system and real-time UI updates

## Future Enhancements

1. **Budget Setting**: Allow users to set budget limits for categories
2. **Export Functionality**: Enable exporting data to CSV/PDF
3. **Cloud Sync**: Add option to sync data across devices
4. **More Visualization**: Add more chart types and insights
5. **Custom Categories**: Allow users to create custom categories
6. **Recurring Transaction Detection**: Identify and highlight regular payments
7. **Notifications**: Send alerts for unusual spending patterns
8. **Multiple Currency Support**: Handle transactions in different currencies

## Conclusion

FinMind provides a comprehensive solution for automated financial tracking by leveraging existing bank SMS notifications. This approach eliminates the need for manual transaction entry while providing powerful analysis tools to help users gain insights into their financial habits.

The application demonstrates effective use of Flutter's capabilities for creating responsive UIs, managing application state, and handling device features like SMS access while maintaining good performance and user experience.
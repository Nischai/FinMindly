# FinMind - Automated Finance Tracker

FinMind is a Flutter application that automatically tracks your financial transactions by reading and parsing bank SMS messages. It provides insightful statistics on daily spending and income patterns.

## Features

- **SMS Permission Handling**: Requests SMS reading permission on first launch
- **Automatic Transaction Detection**: Parses bank SMS messages to extract transaction details
- **Transaction Categorization**: Automatically categorizes expenses and income
- **Daily Statistics**: Displays daily financial activity charts
- **Category Analysis**: Shows spending breakdown by category
- **Transaction History**: View and filter transaction history

## Setup Instructions

### Prerequisites

- Flutter SDK (3.2.0 or higher)
- Android Studio or Visual Studio Code
- A physical Android device for testing (SMS reading works better on physical devices)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/finmind.git
   ```

2. Navigate to the project directory:
   ```
   cd finmind
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

### Permissions

This app requires the following permissions:
- `READ_SMS` - To read bank transaction SMS messages
- `RECEIVE_SMS` - To receive and process new bank SMS messages in real-time

These permissions will be requested when the app is first launched.

## How It Works

1. When the app is launched for the first time, it will request SMS reading permissions
2. Once permissions are granted, the app will read your SMS inbox and parse messages from common bank senders
3. The app extracts transaction details (amount, date, description) from these messages
4. Transactions are categorized automatically based on keywords
5. The app presents statistics and visualizations of your spending patterns

## Supported Banks

The app recognizes SMS messages from common Indian banks including:
- HDFC Bank
- State Bank of India
- ICICI Bank
- Axis Bank
- Kotak Mahindra Bank
- Punjab National Bank
- Bank of India
- YES Bank
- Canara Bank
- Central Bank of India
- And more

## Customization

You can customize the bank sender IDs by modifying the `_bankSenders` list in `lib/services/sms_service.dart`.

## Privacy Notice

This app processes your SMS data locally on your device. No data is transmitted to external servers or shared with third parties.
enum AccountType { bank, creditCard, debitCard, investment, insurance, other }

class Account {
  final String id;
  final String name;
  final String? logo;
  final AccountType type;
  final String? lastFourDigits;
  final double balance;
  final String? bankName;
  final String? color; // For UI customization

  Account({
    required this.id,
    required this.name,
    this.logo,
    required this.type,
    this.lastFourDigits,
    required this.balance,
    this.bankName,
    this.color,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo': logo,
      'type': type.toString(),
      'lastFourDigits': lastFourDigits,
      'balance': balance,
      'bankName': bankName,
      'color': color,
    };
  }

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'],
      name: json['name'],
      logo: json['logo'],
      type: _typeFromString(json['type']),
      lastFourDigits: json['lastFourDigits'],
      balance: json['balance'],
      bankName: json['bankName'],
      color: json['color'],
    );
  }

  static AccountType _typeFromString(String typeStr) {
    switch (typeStr) {
      case 'AccountType.bank':
        return AccountType.bank;
      case 'AccountType.creditCard':
        return AccountType.creditCard;
      case 'AccountType.debitCard':
        return AccountType.debitCard;
      case 'AccountType.investment':
        return AccountType.investment;
      case 'AccountType.insurance':
        return AccountType.insurance;
      default:
        return AccountType.other;
    }
  }

  // Get an icon based on account type
  String get icon {
    switch (type) {
      case AccountType.bank:
        return 'assets/icons/bank.png';
      case AccountType.creditCard:
        return 'assets/icons/credit_card.png';
      case AccountType.debitCard:
        return 'assets/icons/debit_card.png';
      case AccountType.investment:
        return 'assets/icons/investment.png';
      case AccountType.insurance:
        return 'assets/icons/insurance.png';
      case AccountType.other:
        return 'assets/icons/wallet.png';
    }
  }

  // Create a display name combining bank name and last 4 digits
  String get displayName {
    if (type == AccountType.bank ||
        type == AccountType.creditCard ||
        type == AccountType.debitCard) {
      if (lastFourDigits != null && bankName != null) {
        return '$bankName ••••$lastFourDigits';
      } else if (lastFourDigits != null) {
        return '••••$lastFourDigits';
      } else if (bankName != null) {
        return bankName!;
      }
    }
    return name;
  }
}

class TransactionModel {
  final String title;
  final double amount;
  final bool isIncome;
  final DateTime date;

  TransactionModel({
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'amount': amount,
        'isIncome': isIncome,
        'date': date.toIso8601String(),
      };

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      title: json['title'],
      amount: json['amount'],
      isIncome: json['isIncome'],
      date: DateTime.parse(json['date']),
    );
  }
}

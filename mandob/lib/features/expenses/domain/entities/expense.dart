import 'package:equatable/equatable.dart';

class Expense extends Equatable {
  final int id;
  final String title;
  final String category;
  final double amount;
  final String expenseDate;
  final String? notes;
  final String createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.expenseDate,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        category,
        amount,
        expenseDate,
        notes,
        createdAt,
      ];
}

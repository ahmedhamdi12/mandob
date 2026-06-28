import '../../domain/entities/expense.dart';

class ExpenseModel extends Expense {
  const ExpenseModel({
    required super.id,
    required super.title,
    required super.category,
    required super.amount,
    required super.expenseDate,
    super.notes,
    required super.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int,
      title: map['title'] as String,
      category: map['category'] as String,
      amount: (map['amount'] as num).toDouble(),
      expenseDate: map['expense_date'] as String,
      notes: map['notes'] as String?,
      createdAt: map['created_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id > 0) 'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'expense_date': expenseDate,
      'notes': notes,
      if (id <= 0) 'created_at': createdAt,
    };
  }

  factory ExpenseModel.fromEntity(Expense entity) {
    return ExpenseModel(
      id: entity.id,
      title: entity.title,
      category: entity.category,
      amount: entity.amount,
      expenseDate: entity.expenseDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
    );
  }
}

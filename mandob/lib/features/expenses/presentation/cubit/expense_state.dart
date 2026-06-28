import 'package:equatable/equatable.dart';
import '../../domain/entities/expense.dart';

abstract class ExpenseState extends Equatable {
  const ExpenseState();

  @override
  List<Object> get props => [];
}

class ExpenseInitial extends ExpenseState {}

class ExpenseLoading extends ExpenseState {}

class ExpensesLoaded extends ExpenseState {
  final List<Expense> expenses;
  final double totalAmount;

  const ExpensesLoaded({required this.expenses, required this.totalAmount});

  @override
  List<Object> get props => [expenses, totalAmount];
}

class ExpenseSuccess extends ExpenseState {
  final String message;

  const ExpenseSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class ExpenseError extends ExpenseState {
  final String message;

  const ExpenseError(this.message);

  @override
  List<Object> get props => [message];
}

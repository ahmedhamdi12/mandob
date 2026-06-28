import '../entities/expense.dart';

abstract class ExpenseRepository {
  Future<int> addExpense(Expense expense);
  Future<List<Expense>> getExpenses({String? startDate, String? endDate, String? category});
  Future<double> getTotalExpenses({String? date});
}

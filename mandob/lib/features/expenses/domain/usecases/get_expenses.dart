import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class GetExpenses {
  final ExpenseRepository repository;

  GetExpenses(this.repository);

  Future<List<Expense>> call({String? startDate, String? endDate, String? category}) {
    return repository.getExpenses(startDate: startDate, endDate: endDate, category: category);
  }
}

import '../repositories/expense_repository.dart';

class GetTotalExpenses {
  final ExpenseRepository repository;

  GetTotalExpenses(this.repository);

  Future<double> call({String? date}) {
    return repository.getTotalExpenses(date: date);
  }
}

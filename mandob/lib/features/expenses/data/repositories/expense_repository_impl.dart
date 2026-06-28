import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/expense_local_datasource.dart';
import '../models/expense_model.dart';

class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseLocalDataSource localDataSource;

  ExpenseRepositoryImpl({required this.localDataSource});

  @override
  Future<int> addExpense(Expense expense) async {
    final model = ExpenseModel.fromEntity(expense);
    return await localDataSource.addExpense(model);
  }

  @override
  Future<List<Expense>> getExpenses({String? startDate, String? endDate, String? category}) async {
    return await localDataSource.getExpenses(startDate: startDate, endDate: endDate, category: category);
  }

  @override
  Future<double> getTotalExpenses({String? date}) async {
    return await localDataSource.getTotalExpenses(date: date);
  }
}

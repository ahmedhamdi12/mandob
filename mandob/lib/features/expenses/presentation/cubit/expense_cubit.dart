import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/expense.dart';
import '../../domain/usecases/add_expense.dart';
import '../../domain/usecases/get_expenses.dart';
import '../../domain/usecases/get_total_expenses.dart';
import 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final AddExpense addExpenseUseCase;
  final GetExpenses getExpensesUseCase;
  final GetTotalExpenses getTotalExpensesUseCase;

  ExpenseCubit({
    required this.addExpenseUseCase,
    required this.getExpensesUseCase,
    required this.getTotalExpensesUseCase,
  }) : super(ExpenseInitial());

  Future<void> loadExpenses({String? startDate, String? endDate, String? category}) async {
    emit(ExpenseLoading());
    try {
      final expenses = await getExpensesUseCase(
        startDate: startDate,
        endDate: endDate,
        category: category,
      );
      
      // Calculate total from the loaded list
      final totalAmount = expenses.fold(0.0, (sum, item) => sum + item.amount);
      
      emit(ExpensesLoaded(expenses: expenses, totalAmount: totalAmount));
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }

  Future<void> addExpense(Expense expense) async {
    emit(ExpenseLoading());
    try {
      await addExpenseUseCase(expense);
      emit(const ExpenseSuccess('تم إضافة المصروف بنجاح'));
      loadExpenses();
    } catch (e) {
      emit(ExpenseError(e.toString()));
    }
  }
}

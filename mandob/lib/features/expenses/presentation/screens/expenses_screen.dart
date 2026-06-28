import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/empty_state_widget.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/theme/app_colors.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpenseCubit>().loadExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصروفات'),
      ),
      body: BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is ExpenseError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const LoadingWidget();
          } else if (state is ExpensesLoaded) {
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      const Text('إجمالي المصروفات', style: TextStyle(fontSize: 16)),
                      Text(
                        NumberUtils.formatCurrency(state.totalAmount),
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.expenses.isEmpty
                    ? const EmptyStateWidget(
                        iconData: Icons.money_off,
                        message: 'لا يوجد مصروفات مضافة',
                      )
                    : ListView.builder(
                        itemCount: state.expenses.length,
                        itemBuilder: (context, index) {
                          final expense = state.expenses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.receipt),
                              ),
                              title: Text(expense.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(expense.category),
                                  Text(expense.expenseDate.split('T').first),
                                ],
                              ),
                              trailing: Text(
                                NumberUtils.formatCurrency(expense.amount),
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                          );
                        },
                      ),
                ),
              ],
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/expenses/new').then((_) {
            if (context.mounted) {
              context.read<ExpenseCubit>().loadExpenses();
            }
          });
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة مصروف'),
      ),
    );
  }
}

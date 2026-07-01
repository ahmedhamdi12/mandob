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
  String? _selectedMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    _loadData();
  }

  void _loadData() {
    context.read<ExpenseCubit>().loadExpenses(
      startDate: '$_selectedMonth-01',
      endDate: '$_selectedMonth-31',
    );
  }

  Future<void> _pickMonth() async {
    final now = DateTime.now();
    final initialDate = _selectedMonth != null 
        ? DateTime.parse('$_selectedMonth-01') 
        : now;
        
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 1),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = '${picked.year}-${picked.month.toString().padLeft(2, '0')}';
      });
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المصروفات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickMonth,
          ),
        ],
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
                      Text('إجمالي مصروفات ($_selectedMonth)', style: const TextStyle(fontSize: 16)),
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

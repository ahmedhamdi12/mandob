import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/expense_cubit.dart';
import '../cubit/expense_state.dart';
import '../../domain/entities/expense.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/input_validators.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  
  String _selectedCategory = 'أخرى';
  final List<String> _categories = [
    'وقود',
    'طعام',
    'صيانة سيارة',
    'غسيل سيارة',
    'رسوم تحميل',
    'أخرى',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final expense = Expense(
        id: 0,
        title: _titleController.text,
        category: _selectedCategory,
        amount: double.parse(_amountController.text),
        expenseDate: AppDateUtils.getCurrentIso(),
        notes: _notesController.text,
        createdAt: AppDateUtils.getCurrentIso(),
      );
      
      context.read<ExpenseCubit>().addExpense(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إضافة مصروف')),
      body: BlocConsumer<ExpenseCubit, ExpenseState>(
        listener: (context, state) {
          if (state is ExpenseSuccess) {
            context.pop();
          }
        },
        builder: (context, state) {
          if (state is ExpenseLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  initialValue: _selectedCategory,
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _selectedCategory = val);
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'العنوان / الوصف'),
                  validator: InputValidators.required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'المبلغ'),
                  keyboardType: TextInputType.number,
                  validator: InputValidators.required,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(labelText: 'ملاحظات (اختياري)'),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _save,
                  child: const Text('حفظ المصروف'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

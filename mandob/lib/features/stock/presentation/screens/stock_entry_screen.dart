import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import '../widgets/stock_entry_form.dart';

class StockEntryScreen extends StatelessWidget {
  const StockEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة مشتريات للمخزون'),
      ),
      body: BlocConsumer<StockCubit, StockState>(
        listener: (context, state) {
          if (state is StockSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          } else if (state is StockError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          if (state is StockLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return const StockEntryForm();
        },
      ),
    );
  }
}

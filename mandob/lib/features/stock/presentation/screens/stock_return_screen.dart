import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/stock_cubit.dart';
import '../cubit/stock_state.dart';
import '../../../products/presentation/cubit/product_cubit.dart';
import '../../../products/presentation/cubit/product_state.dart';
import '../../../../core/theme/app_colors.dart';

class StockReturnScreen extends StatefulWidget {
  const StockReturnScreen({super.key});

  @override
  State<StockReturnScreen> createState() => _StockReturnScreenState();
}

class _StockReturnScreenState extends State<StockReturnScreen> {
  final _formKey = GlobalKey<FormState>();
  final _qtyController = TextEditingController();
  
  int? _selectedProductId;

  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedProductId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار المنتج')),
        );
        return;
      }
      
      final qty = int.parse(_qtyController.text);
      context.read<StockCubit>().returnStock(_selectedProductId!, qty);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مرتجع مخزون للمخزن'),
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
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                  ),
                  child: const Text(
                    'هذه الشاشة تستخدم لإرجاع بضاعة من العربية (المخزون الحالي) إلى المخزن الأساسي. سيتم خصم الكمية المحددة من مخزونك الحالي على النظام.',
                    style: TextStyle(color: AppColors.primary, height: 1.5),
                  ),
                ),
                const SizedBox(height: 24),
                BlocBuilder<ProductCubit, ProductState>(
                  builder: (context, productState) {
                    if (productState is ProductsLoaded) {
                      return DropdownButtonFormField<int>(
                        initialValue: _selectedProductId,
                        decoration: const InputDecoration(
                          labelText: 'المنتج',
                          prefixIcon: Icon(Icons.inventory),
                        ),
                        items: productState.products.map((p) {
                          return DropdownMenuItem(
                            value: p.id,
                            child: Text('${p.name} (المتاح: ${p.stockQty})'),
                          );
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedProductId = val),
                        validator: (val) => val == null ? 'مطلوب' : null,
                      );
                    }
                    return const CircularProgressIndicator();
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _qtyController,
                  decoration: const InputDecoration(
                    labelText: 'الكمية المرتجعة',
                    prefixIcon: Icon(Icons.format_list_numbered),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.isEmpty) return 'مطلوب';
                    if (int.tryParse(val) == null || int.parse(val) <= 0) {
                      return 'قيمة غير صالحة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                if (state is StockLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('تأكيد المرتجع'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

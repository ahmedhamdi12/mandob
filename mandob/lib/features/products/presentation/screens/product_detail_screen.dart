import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../stock/data/datasources/stock_local_datasource.dart';
import '../../../stock/data/models/stock_purchase_model.dart';
import '../../domain/entities/product.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<StockPurchaseModel>? _purchaseHistory;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final stockDataSource = sl<StockLocalDataSource>();
      final history = await stockDataSource.getProductPurchaseHistory(widget.productId);
      if (mounted) {
        setState(() {
          _purchaseHistory = history;
          _isLoadingHistory = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingHistory = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'تعديل المنتج',
            onPressed: () {
              context.push('/products/edit/${widget.productId}').then((_) {
                // Refresh data if changed
                if (context.mounted) {
                  context.read<ProductCubit>().loadProducts();
                }
                _loadHistory();
              });
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          Product? product;
          
          if (state is ProductsLoaded) {
            product = state.products.cast<Product?>().firstWhere(
                  (p) => p?.id == widget.productId,
                  orElse: () => null,
                );
          }

          if (product == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Product Info Card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: AppTextStyles.h2),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('الوحدة: ${product.baseUnit}', style: AppTextStyles.bodyLarge),
                              const SizedBox(height: 8),
                              Text(
                                'آخر سعر شراء: ${product.lastPurchasePrice != null ? NumberUtils.formatCurrency(product.lastPurchasePrice!) : "لا يوجد"}',
                                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.primary),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            decoration: BoxDecoration(
                              color: product.stockQty <= product.lowStockThreshold 
                                  ? AppColors.error.withValues(alpha: 0.1) 
                                  : AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                Text('المخزون', style: AppTextStyles.caption),
                                Text(
                                  '${product.stockQty}',
                                  style: AppTextStyles.h2.copyWith(
                                    color: product.stockQty <= product.lowStockThreshold 
                                        ? AppColors.error 
                                        : AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Timeline
              Text('سجل المشتريات (التايم لاين)', style: AppTextStyles.h3),
              const SizedBox(height: 16),
              
              if (_isLoadingHistory)
                const Center(child: CircularProgressIndicator())
              else if (_purchaseHistory == null || _purchaseHistory!.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(
                      child: Text('لا توجد عمليات شراء مسجلة لهذا المنتج.'),
                    ),
                  ),
                )
              else
                ..._purchaseHistory!.map((purchase) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: Icon(Icons.download, color: Colors.white, size: 20),
                    ),
                    title: Text('${purchase.qtyUnits} ${product!.baseUnit}'),
                    subtitle: Text(purchase.purchaseDate.split('T').first),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          NumberUtils.formatCurrency(purchase.costPerUnit),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary),
                        ),
                        Text(
                          'الإجمالي: ${NumberUtils.formatCurrency(purchase.qtyUnits * purchase.costPerUnit)}',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ),
                )),
            ],
          );
        },
      ),
    );
  }
}

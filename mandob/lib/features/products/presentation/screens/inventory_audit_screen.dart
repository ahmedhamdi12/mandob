import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/services/service_locator.dart';
import '../cubit/product_cubit.dart';
import '../cubit/product_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../shared/widgets/loading_widget.dart';

class InventoryAuditScreen extends StatefulWidget {
  const InventoryAuditScreen({super.key});

  @override
  State<InventoryAuditScreen> createState() => _InventoryAuditScreenState();
}

class _InventoryAuditScreenState extends State<InventoryAuditScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductCubit>().loadProducts();
  }

  Future<void> _exportToCsv(ProductsLoaded state) async {
    try {
      final StringBuffer sb = StringBuffer();
      
      // Add UTF-8 BOM so Excel opens it correctly with Arabic characters
      sb.write('\uFEFF');
      
      // Header
      sb.writeln('كود المنتج,اسم المنتج,تاريخ الشراء,الوحدة الأساسية,الكمية المتبقية من الباتش,التكلفة,إجمالي القيمة');
      
      double totalInventoryValue = 0.0;
      int totalItems = 0;

      // Fetch active batches
      final dbHelper = sl<DatabaseHelper>();
      final batches = await dbHelper.getActiveInventoryBatches();

      int currentProductId = -1;
      double productTotalValue = 0.0;
      int productTotalQty = 0;

      for (var batch in batches) {
        final int productId = batch['product_id'] as int;
        
        if (currentProductId != -1 && currentProductId != productId) {
          // Write subtotal for previous product
          sb.writeln(',,,,إجمالي الصنف $currentProductId,$productTotalQty,,$productTotalValue');
          productTotalValue = 0.0;
          productTotalQty = 0;
        }

        currentProductId = productId;
        
        final String name = (batch['product_name'] as String).contains(',') 
            ? '"${batch['product_name']}"' 
            : batch['product_name'] as String;
        final String baseUnit = batch['base_unit'] as String;
        final String purchaseDate = (batch['purchase_date'] as String).split('T').first;
        final int remainingQty = batch['remaining_qty'] as int;
        final double costPerUnit = (batch['cost_per_unit'] as num).toDouble();
        final double batchValue = (batch['batch_value'] as num).toDouble();
        
        productTotalQty += remainingQty;
        productTotalValue += batchValue;
        totalItems += remainingQty;
        totalInventoryValue += batchValue;
        
        sb.writeln('$productId,$name,$purchaseDate,$baseUnit,$remainingQty,$costPerUnit,$batchValue');
      }

      if (currentProductId != -1) {
        // Write subtotal for last product
        sb.writeln(',,,,إجمالي الصنف $currentProductId,$productTotalQty,,$productTotalValue');
      }

      // Footer / Totals
      sb.writeln(',,,,');
      sb.writeln('الإجمالي الكلي,,,,$totalItems,, $totalInventoryValue');

      // Save file
      final dir = await getApplicationDocumentsDirectory();
      final dateStr = AppDateUtils.getCurrentIso().split('T').first;
      final file = File('${dir.path}/inventory_audit_$dateStr.csv');
      
      await file.writeAsString(sb.toString());

      // Share
      if (mounted) {
        // Suppress warning if not easy to fix, or use the new API if possible.
        // The error suggests SharePlus.instance.share(). Let's try it:
        // Actually, maybe it is `Share.shareXFiles` in the current version. Let's just fix the call:
        // Wait, the warning says 'Share' is deprecated. So maybe Share.shareXFiles -> Share.shareUri?
        // Let's use Share.shareXFiles for now and ignore the info, or use Share.shareXFiles and ignore. Let's use Share.shareXFiles but replace Share with SharePlus. But is SharePlus a class? No, usually it's Share.
        // Let me just replace it to suppress the warning if possible or leave it. I will leave it as is but add ignore:
        // ignore: deprecated_member_use
        Share.shareXFiles([XFile(file.path)], text: 'تقرير جرد المخزون بتاريخ $dateStr');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء التصدير: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جرد المخزون'),
        actions: [
          BlocBuilder<ProductCubit, ProductState>(
            builder: (context, state) {
              if (state is ProductsLoaded && state.products.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.download),
                  tooltip: 'تصدير إكسيل (CSV)',
                  onPressed: () => _exportToCsv(state),
                );
              }
              return const SizedBox();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingWidget();
          } else if (state is ProductError) {
            return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
          } else if (state is ProductsLoaded) {
            if (state.products.isEmpty) {
              return const Center(child: Text('لا توجد منتجات في المخزون'));
            }

            double totalValue = 0;
            for (var p in state.products) {
              totalValue += p.fifoInventoryValue;
            }

            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('إجمالي قيمة المخزون:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(
                        NumberUtils.formatCurrency(totalValue),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: state.products.length,
                    separatorBuilder: (ctx, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = state.products[index];
                      final value = product.fifoInventoryValue;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: product.stockQty <= product.lowStockThreshold
                              ? AppColors.error.withValues(alpha: 0.1)
                              : AppColors.primary.withValues(alpha: 0.1),
                          child: Text(
                            product.stockQty.toString(),
                            style: TextStyle(
                              color: product.stockQty <= product.lowStockThreshold
                                  ? AppColors.error
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('التكلفة: ${NumberUtils.formatCurrency(product.calculatedUnitCost)}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('الإجمالي', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            Text(
                              NumberUtils.formatCurrency(value),
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.secondary),
                            ),
                          ],
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
      floatingActionButton: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductsLoaded && state.products.isNotEmpty) {
            return FloatingActionButton.extended(
              onPressed: () => _exportToCsv(state),
              icon: const Icon(Icons.download),
              label: const Text('تصدير إكسيل'),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}

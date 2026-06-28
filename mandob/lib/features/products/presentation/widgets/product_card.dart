import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_utils.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isLowStock = product.stockQty <= product.lowStockThreshold;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: AppTextStyles.h3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.inventory_2, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'الوحدة الأساسية: ${product.baseUnit}',
                          style: AppTextStyles.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          'آخر سعر شراء: ${product.lastPurchasePrice != null ? NumberUtils.formatCurrency(product.lastPurchasePrice!) : "لا يوجد"}',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isLowStock ? AppColors.error.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${product.stockQty}',
                      style: AppTextStyles.h4.copyWith(
                        color: isLowStock ? AppColors.error : AppColors.primary,
                      ),
                    ),
                  ),
                  if (isLowStock) ...[
                    const SizedBox(height: 4),
                    Text(
                      'ناقص',
                      style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

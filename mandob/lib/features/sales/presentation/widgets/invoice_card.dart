import 'package:flutter/material.dart';
import '../../domain/entities/invoice.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_utils.dart';

class InvoiceCard extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback? onTap;

  const InvoiceCard({
    super.key,
    required this.invoice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCancelled = invoice.status == 'cancelled';
    
    return Card(
      color: isCancelled ? Colors.grey[200] : AppColors.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    invoice.invoiceNumber,
                    style: AppTextStyles.h4.copyWith(
                      decoration: isCancelled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isCancelled ? AppColors.error.withValues(alpha: 0.1) : AppColors.success.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isCancelled ? 'ملغاة' : 'نشطة',
                      style: AppTextStyles.caption.copyWith(
                        color: isCancelled ? AppColors.error : AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'عميل رقم: ${invoice.customerId}', // Better to pass customer name if available
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                  const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    invoice.invoiceDate.split('T').first,
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الإجمالي', style: AppTextStyles.caption),
                      Text(
                        NumberUtils.formatCurrency(invoice.totalAmount),
                        style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('المدفوع', style: AppTextStyles.caption),
                      Text(
                        NumberUtils.formatCurrency(invoice.paidAmount),
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('المتبقي', style: AppTextStyles.caption),
                      Text(
                        NumberUtils.formatCurrency(invoice.remaining),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: invoice.remaining > 0 ? AppColors.error : AppColors.textPrimary,
                        ),
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

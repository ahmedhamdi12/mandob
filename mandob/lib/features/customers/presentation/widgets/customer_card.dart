import 'package:flutter/material.dart';
import '../../domain/entities/customer.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/number_utils.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback? onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: AppTextStyles.h3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (customer.phone.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            customer.phone,
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('الرصيد', style: AppTextStyles.caption),
                  Text(
                    NumberUtils.formatCurrency(customer.currentBalance),
                    style: AppTextStyles.h4.copyWith(
                      color: customer.currentBalance < 0
                          ? AppColors.error
                          : (customer.currentBalance > 0 ? AppColors.success : AppColors.textPrimary),
                    ),
                    textDirection: TextDirection.ltr,
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

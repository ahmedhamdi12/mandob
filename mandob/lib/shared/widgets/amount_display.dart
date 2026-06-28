import 'package:flutter/material.dart';
import '../../core/utils/number_utils.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart';

class AmountDisplay extends StatelessWidget {
  final double amount;
  final TextStyle? style;
  final bool isNegative;
  final bool isPositive;

  const AmountDisplay({
    super.key,
    required this.amount,
    this.style,
    this.isNegative = false,
    this.isPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    Color? textColor;
    if (isNegative) textColor = AppColors.error;
    if (isPositive) textColor = AppColors.success;

    final mergedStyle = style ?? AppTextStyles.h4;
    final finalStyle = textColor != null ? mergedStyle.copyWith(color: textColor) : mergedStyle;

    return Text(
      NumberUtils.formatCurrency(amount),
      style: finalStyle,
      textDirection: TextDirection.ltr,
    );
  }
}

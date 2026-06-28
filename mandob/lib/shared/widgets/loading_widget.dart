import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class LoadingWidget extends StatelessWidget {
  final bool isOverlay;

  const LoadingWidget({super.key, this.isOverlay = false});

  @override
  Widget build(BuildContext context) {
    final indicator = const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
    );

    if (isOverlay) {
      return Container(
        color: Colors.black45,
        alignment: Alignment.center,
        child: indicator,
      );
    }

    return Center(child: indicator);
  }
}

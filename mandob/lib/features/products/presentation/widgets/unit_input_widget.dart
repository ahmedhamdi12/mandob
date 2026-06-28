import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/input_validators.dart';

class UnitInputWidget extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController factorController;
  final VoidCallback onRemove;
  final String baseUnit;

  const UnitInputWidget({
    super.key,
    required this.nameController,
    required this.factorController,
    required this.onRemove,
    required this.baseUnit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'اسم الوحدة',
                hintText: 'مثال: كرتونة',
              ),
              validator: InputValidators.required,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: TextFormField(
              controller: factorController,
              decoration: InputDecoration(
                labelText: 'تساوي كم $baseUnit؟',
                hintText: 'مثال: 12',
              ),
              keyboardType: TextInputType.number,
              validator: InputValidators.positiveNumber,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle, color: AppColors.error),
            onPressed: onRemove,
          ),
        ],
      ),
    );
  }
}

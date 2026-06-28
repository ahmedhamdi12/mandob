import 'package:flutter/material.dart';

class PaymentTypeSelector extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onChanged;

  const PaymentTypeSelector({
    super.key,
    required this.selectedType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ListTile(
            title: const Text('كاش'),
            leading: Radio<String>(
              value: 'cash',
              // ignore: deprecated_member_use
              groupValue: selectedType,
              // ignore: deprecated_member_use
              onChanged: (val) => onChanged(val!),
            ),
            onTap: () => onChanged('cash'),
          ),
        ),
        Expanded(
          child: ListTile(
            title: const Text('آجل'),
            leading: Radio<String>(
              value: 'credit',
              // ignore: deprecated_member_use
              groupValue: selectedType,
              // ignore: deprecated_member_use
              onChanged: (val) => onChanged(val!),
            ),
            onTap: () => onChanged('credit'),
          ),
        ),
      ],
    );
  }
}

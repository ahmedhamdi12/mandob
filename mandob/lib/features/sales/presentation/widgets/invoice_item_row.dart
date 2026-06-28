import 'package:flutter/material.dart';
import '../../domain/entities/invoice_item.dart';
import '../../../products/domain/entities/product.dart';
import '../../../../core/utils/number_utils.dart';

class InvoiceItemRow extends StatelessWidget {
  final InvoiceItem item;
  final Product product;
  final VoidCallback onRemove;

  const InvoiceItemRow({
    super.key,
    required this.item,
    required this.product,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Text(
                    '${item.displayQty} × ${NumberUtils.formatCurrency(item.unitPrice)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Text(
              NumberUtils.formatCurrency(item.lineTotal),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor),
              textDirection: TextDirection.ltr,
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}

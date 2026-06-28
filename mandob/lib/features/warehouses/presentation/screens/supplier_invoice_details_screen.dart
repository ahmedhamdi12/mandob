import 'package:flutter/material.dart';

class SupplierInvoiceDetailsScreen extends StatelessWidget {
  final int invoiceId;
  const SupplierInvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    // Basic placeholder for now, would fetch from cubit like others
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الفاتورة')),
      body: Center(child: Text('Invoice ID: $invoiceId')),
    );
  }
}

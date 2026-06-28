import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../cubit/invoice_cubit.dart';

import '../../../../core/services/service_locator.dart';
import '../../../../core/utils/number_utils.dart';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';

class InvoiceDetailsScreen extends StatefulWidget {
  final int invoiceId;

  const InvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  State<InvoiceDetailsScreen> createState() => _InvoiceDetailsScreenState();
}

class _InvoiceDetailsScreenState extends State<InvoiceDetailsScreen> {
  Invoice? _invoice;
  List<InvoiceItem>? _items;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final repository = sl<InvoiceCubit>().repository;
      final invoice = await repository.getInvoiceById(widget.invoiceId);
      final items = await repository.getInvoiceItems(widget.invoiceId);
      
      if (mounted) {
        setState(() {
          _invoice = invoice;
          _items = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading invoice: $e')),
        );
      }
    }
  }

  void _confirmCancel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل أنت متأكد من إلغاء الفاتورة وإرجاع البضاعة للمخزن؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('تراجع'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<InvoiceCubit>().cancelInvoice(widget.invoiceId);
              context.pop();
            },
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );
  }

  void _shareInvoice() {
    if (_invoice == null) return;
    
    final StringBuffer sb = StringBuffer();
    sb.writeln('فاتورة مبيعات: ${_invoice!.invoiceNumber}');
    sb.writeln('التاريخ: ${_invoice!.invoiceDate.split('T').first}');
    sb.writeln('العميل: ${_invoice!.customerName ?? 'عميل رقم ${_invoice!.customerId}'}');
    if (_invoice!.customerPhone != null && _invoice!.customerPhone!.isNotEmpty) {
      sb.writeln('الموبايل: ${_invoice!.customerPhone}');
    }
    sb.writeln('---------------------------');
    sb.writeln('المنتج | العدد | السعر | الإجمالي');
    if (_items != null) {
      for (var item in _items!) {
        final String name = item.productName ?? 'منتج ${item.productId}';
        final String qty = item.displayQty?.toStringAsFixed(1) ?? item.qtyUnits.toString();
        final String price = NumberUtils.formatCurrency(item.unitPrice);
        final String total = NumberUtils.formatCurrency(item.lineTotal);
        sb.writeln('$name | $qty | $price | $total');
      }
    }
    sb.writeln('---------------------------');
    sb.writeln('الإجمالي الكلي: ${NumberUtils.formatCurrency(_invoice!.totalAmount)}');
    sb.writeln('المدفوع: ${NumberUtils.formatCurrency(_invoice!.paidAmount)}');
    sb.writeln('المتبقي: ${NumberUtils.formatCurrency(_invoice!.remaining)}');
    
    Share.share(sb.toString());
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الفاتورة')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('تفاصيل الفاتورة')),
        body: const Center(child: Text('الفاتورة غير موجودة')),
      );
    }

    final isCancelled = _invoice!.status == 'cancelled';

    return Scaffold(
      appBar: AppBar(
        title: Text(_invoice!.invoiceNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة الفاتورة',
            onPressed: _shareInvoice,
          ),
          if (!isCancelled)
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              tooltip: 'إلغاء الفاتورة',
              onPressed: _confirmCancel,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (isCancelled)
            Container(
              padding: const EdgeInsets.all(12),
              color: Colors.red.withValues(alpha: 0.1),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.red),
                  SizedBox(width: 8),
                  Text('هذه الفاتورة ملغاة', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('اسم العميل: ${_invoice!.customerName ?? 'عميل رقم ${_invoice!.customerId}'}', style: Theme.of(context).textTheme.titleLarge),
                  if (_invoice!.customerPhone != null && _invoice!.customerPhone!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('رقم التليفون: ${_invoice!.customerPhone}', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 8),
                  Text('التاريخ: ${_invoice!.invoiceDate}'),
                  Text('طريقة الدفع: ${_invoice!.paymentType == 'cash' ? 'كاش' : 'آجل'}'),
                  if (_invoice!.notes != null && _invoice!.notes!.isNotEmpty)
                    Text('ملاحظات: ${_invoice!.notes}'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('الأصناف (${_items?.length ?? 0})', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          
          if (_items != null && _items!.isNotEmpty)
            Card(
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  columns: const [
                    DataColumn(label: Text('المنتج')),
                    DataColumn(label: Text('العدد')),
                    DataColumn(label: Text('السعر')),
                    DataColumn(label: Text('المجموع')),
                  ],
                  rows: _items!.map((item) => DataRow(
                    cells: [
                      DataCell(Text(item.productName ?? 'منتج رقم ${item.productId}')),
                      DataCell(Text(item.displayQty?.toStringAsFixed(1) ?? item.qtyUnits.toString())),
                      DataCell(Text(NumberUtils.formatCurrency(item.unitPrice))),
                      DataCell(Text(NumberUtils.formatCurrency(item.lineTotal), style: const TextStyle(fontWeight: FontWeight.bold))),
                    ],
                  )).toList(),
                ),
              ),
            ),
            
          const SizedBox(height: 24),
          Card(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي', style: TextStyle(fontSize: 18)),
                      Text(NumberUtils.formatCurrency(_invoice!.totalAmount), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المدفوع', style: TextStyle(color: Colors.green)),
                      Text(NumberUtils.formatCurrency(_invoice!.paidAmount), style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('المتبقي', style: TextStyle(color: Colors.red)),
                      Text(NumberUtils.formatCurrency(_invoice!.remaining), style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

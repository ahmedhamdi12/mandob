import 'package:flutter/material.dart';
import '../../domain/entities/supplier_invoice.dart';
import '../../domain/entities/supplier_invoice_item.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../../../core/utils/number_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/services/service_locator.dart';

class SupplierInvoiceDetailsScreen extends StatefulWidget {
  final int invoiceId;
  const SupplierInvoiceDetailsScreen({super.key, required this.invoiceId});

  @override
  State<SupplierInvoiceDetailsScreen> createState() => _SupplierInvoiceDetailsScreenState();
}

class _SupplierInvoiceDetailsScreenState extends State<SupplierInvoiceDetailsScreen> {
  SupplierInvoice? _invoice;
  List<SupplierInvoiceItem> _items = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repository = sl<WarehouseRepository>();
      final invoice = await repository.getSupplierInvoiceById(widget.invoiceId);
      if (invoice != null) {
        final items = await repository.getSupplierInvoiceItems(widget.invoiceId);
        setState(() {
          _invoice = invoice;
          _items = items;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'الفاتورة غير موجودة';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل فاتورة المورد'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDetails,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_invoice == null) {
      return const Center(child: Text('لا توجد بيانات للفاتورة'));
    }

    final isReturn = _invoice!.type == 'return';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildInfoCard(isReturn),
          const SizedBox(height: 16),
          const Text('الأصناف', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          _buildItemsTable(),
          const SizedBox(height: 24),
          _buildTotalsCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard(bool isReturn) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('رقم الفاتورة: ${_invoice!.invoiceNumber}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isReturn ? Colors.red.withValues(alpha: 0.1) : Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isReturn ? 'مرتجع' : 'شراء',
                    style: TextStyle(color: isReturn ? Colors.red : Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _infoRow('المورد:', _invoice!.supplierName ?? 'غير معروف'),
            _infoRow('تاريخ الفاتورة:', AppDateUtils.formatToDate(_invoice!.invoiceDate)),
            _infoRow('الحالة:', _invoice!.status == 'cancelled' ? 'ملغاة' : 'نشطة'),
            if (_invoice!.notes != null && _invoice!.notes!.isNotEmpty)
              _infoRow('ملاحظات:', _invoice!.notes!),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildItemsTable() {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final item = _items[index];
          return ListTile(
            title: Text(item.itemName),
            subtitle: Text('${NumberUtils.formatCurrency(item.unitPrice)} × ${item.qty}'),
            trailing: Text(
              NumberUtils.formatCurrency(item.lineTotal),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTotalsCard() {
    return Card(
      color: Theme.of(context).primaryColor.withValues(alpha: 0.05),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _totalRow('الإجمالي:', _invoice!.totalAmount),
            const SizedBox(height: 8),
            _totalRow('المدفوع:', _invoice!.paidAmount),
            const Divider(),
            _totalRow('المتبقي:', _invoice!.remaining, isBold: true),
          ],
        ),
      ),
    );
  }

  Widget _totalRow(String label, double value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: isBold ? 18 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          NumberUtils.formatCurrency(value),
          style: TextStyle(fontSize: isBold ? 18 : 16, fontWeight: isBold ? FontWeight.bold : FontWeight.normal),
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import '../../domain/entities/invoice.dart';
import '../../domain/entities/invoice_item.dart';
import '../../domain/usecases/create_invoice.dart';
import '../../domain/usecases/get_last_price.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../products/domain/entities/product.dart';
import '../../../../core/utils/date_utils.dart';
import 'new_invoice_state.dart';

class NewInvoiceCubit extends Cubit<NewInvoiceState> {
  final CreateInvoice createInvoiceUseCase;
  final GetLastPrice getLastPriceUseCase;

  Customer? _selectedCustomer;
  final List<InvoiceItem> _items = [];
  final Map<int, Product> _productsCache = {};
  String _paymentType = 'cash';

  NewInvoiceCubit({
    required this.createInvoiceUseCase,
    required this.getLastPriceUseCase,
  }) : super(NewInvoiceInitial()) {
    _emitUpdatedState();
  }

  void setCustomer(Customer customer) {
    _selectedCustomer = customer;
    _emitUpdatedState();
  }

  Future<void> addOrUpdateItem({
    required Product product,
    required double displayQty,
    required int qtyUnits,
    required double unitPrice,
  }) async {
    _productsCache[product.id] = product;

    // Check if product already exists in invoice
    final existingIndex = _items.indexWhere((item) => item.productId == product.id);

    if (existingIndex >= 0) {
      // Update existing
      _items[existingIndex] = InvoiceItem(
        id: 0,
        invoiceId: 0,
        productId: product.id,
        qtyUnits: qtyUnits,
        displayQty: displayQty,
        unitPrice: unitPrice,
        costAtSale: 0.0,
        lineTotal: displayQty * unitPrice,
      );
    } else {
      // Add new
      _items.add(InvoiceItem(
        id: 0,
        invoiceId: 0,
        productId: product.id,
        qtyUnits: qtyUnits,
        displayQty: displayQty,
        unitPrice: unitPrice,
        costAtSale: 0.0,
        lineTotal: displayQty * unitPrice,
      ));
    }
    
    _emitUpdatedState();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    _emitUpdatedState();
  }

  void setPaymentType(String type) {
    _paymentType = type;
    _emitUpdatedState();
  }

  Future<double?> fetchLastPrice(int productId) async {
    if (_selectedCustomer == null) return null;
    final lastPrice = await getLastPriceUseCase(productId, _selectedCustomer!.id);
    return lastPrice?.lastPrice;
  }

  double get _totalAmount {
    return _items.fold(0.0, (sum, item) => sum + item.lineTotal);
  }

  void _emitUpdatedState() {
    emit(NewInvoiceUpdating());
    emit(NewInvoiceUpdated(
      selectedCustomer: _selectedCustomer,
      items: List.from(_items),
      productsCache: Map.from(_productsCache),
      totalAmount: _totalAmount,
      paymentType: _paymentType,
    ));
  }

  Future<void> saveInvoice({required double paidAmount, String? notes, bool isReturn = false}) async {
    if (_selectedCustomer == null || _items.isEmpty) {
      emit(const NewInvoiceError('تأكد من اختيار عميل وإضافة منتجات'));
      _emitUpdatedState();
      return;
    }

    emit(NewInvoiceSaving());

    try {
      final total = _totalAmount;
      final remaining = total - paidAmount;

      final invoiceDate = AppDateUtils.getCurrentIso();
      final dateStr = DateFormat('yyyyMMdd').format(DateTime.now());
      final randomStr = Random().nextInt(999).toString().padLeft(3, '0');
      final prefix = isReturn ? 'RET' : 'INV';
      final invoiceNumber = '$prefix-$dateStr-$randomStr';

      final invoice = Invoice(
        id: 0,
        invoiceNumber: invoiceNumber,
        type: isReturn ? 'return' : 'sale',
        customerId: _selectedCustomer!.id,
        invoiceDate: invoiceDate,
        totalAmount: total,
        paidAmount: paidAmount,
        remaining: remaining,
        paymentType: _paymentType,
        status: 'active',
        notes: notes,
        createdAt: invoiceDate,
      );

      await createInvoiceUseCase(invoice, _items);
      
      emit(const NewInvoiceSuccess('تم حفظ الفاتورة بنجاح'));
    } catch (e) {
      emit(NewInvoiceError('خطأ أثناء حفظ الفاتورة: ${e.toString()}'));
      _emitUpdatedState();
    }
  }
}

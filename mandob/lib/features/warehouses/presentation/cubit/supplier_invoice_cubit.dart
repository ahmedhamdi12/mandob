import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_supplier_invoice.dart';
import '../../domain/entities/supplier_invoice.dart';
import '../../domain/entities/supplier_invoice_item.dart';
import 'supplier_invoice_state.dart';

class SupplierInvoiceCubit extends Cubit<SupplierInvoiceState> {
  final CreateSupplierInvoice createSupplierInvoiceUseCase;

  SupplierInvoiceCubit({required this.createSupplierInvoiceUseCase}) : super(SupplierInvoiceInitial());

  List<SupplierInvoiceItem> currentItems = [];

  void addItem(SupplierInvoiceItem item) {
    currentItems.add(item);
    _emitCurrentItems();
  }

  void removeItem(int index) {
    currentItems.removeAt(index);
    _emitCurrentItems();
  }

  void clearItems() {
    currentItems.clear();
    _emitCurrentItems();
  }

  void _emitCurrentItems() {
    double total = currentItems.fold(0, (sum, item) => sum + item.lineTotal);
    emit(SupplierInvoiceItemAdded(List.from(currentItems), total));
  }

  Future<void> createInvoice(SupplierInvoice invoice) async {
    if (currentItems.isEmpty) {
      emit(SupplierInvoiceError('يجب إضافة أصناف للفاتورة'));
      return;
    }

    emit(SupplierInvoiceLoading());
    try {
      final invoiceId = await createSupplierInvoiceUseCase(invoice, currentItems);
      currentItems.clear();
      emit(SupplierInvoiceSuccess(invoiceId));
    } catch (e) {
      emit(SupplierInvoiceError(e.toString()));
    }
  }
}

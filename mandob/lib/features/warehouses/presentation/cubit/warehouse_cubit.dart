import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_suppliers.dart';
import '../../domain/usecases/add_supplier.dart';
import '../../domain/usecases/update_supplier.dart';
import '../../domain/usecases/delete_supplier.dart';
import '../../domain/usecases/get_supplier_invoices.dart';
import '../../domain/usecases/get_supplier_payments.dart';
import '../../domain/usecases/add_supplier_payment.dart';
import '../../domain/usecases/cancel_supplier_invoice.dart';
import '../../domain/repositories/warehouse_repository.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/entities/supplier_payment.dart';
import 'warehouse_state.dart';

class WarehouseCubit extends Cubit<WarehouseState> {
  final GetSuppliers getSuppliersUseCase;
  final AddSupplier addSupplierUseCase;
  final UpdateSupplier updateSupplierUseCase;
  final DeleteSupplier deleteSupplierUseCase;
  final GetSupplierInvoices getSupplierInvoicesUseCase;
  final GetSupplierPayments getSupplierPaymentsUseCase;
  final AddSupplierPayment addSupplierPaymentUseCase;
  final CancelSupplierInvoice cancelSupplierInvoiceUseCase;
  final WarehouseRepository repository;

  WarehouseCubit({
    required this.getSuppliersUseCase,
    required this.addSupplierUseCase,
    required this.updateSupplierUseCase,
    required this.deleteSupplierUseCase,
    required this.getSupplierInvoicesUseCase,
    required this.getSupplierPaymentsUseCase,
    required this.addSupplierPaymentUseCase,
    required this.cancelSupplierInvoiceUseCase,
    required this.repository,
  }) : super(WarehouseInitial());

  Future<void> loadData() async {
    emit(WarehouseLoading());
    try {
      final suppliers = await getSuppliersUseCase();
      final invoices = await getSupplierInvoicesUseCase();
      final payments = await getSupplierPaymentsUseCase();
      final totalDebt = await repository.getTotalSupplierDebts();

      emit(WarehouseLoaded(
        suppliers: suppliers,
        invoices: invoices,
        payments: payments,
        totalDebt: totalDebt,
      ));
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  Future<void> addSupplier(Supplier supplier) async {
    try {
      await addSupplierUseCase(supplier);
      await loadData();
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  Future<void> updateSupplier(Supplier supplier) async {
    try {
      await updateSupplierUseCase(supplier);
      await loadData();
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  Future<void> deleteSupplier(int id) async {
    try {
      await deleteSupplierUseCase(id);
      await loadData();
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  Future<void> addPayment(SupplierPayment payment) async {
    try {
      await addSupplierPaymentUseCase(payment);
      await loadData();
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }

  Future<void> cancelInvoice(int invoiceId) async {
    try {
      await cancelSupplierInvoiceUseCase(invoiceId);
      await loadData();
    } catch (e) {
      emit(WarehouseError(e.toString()));
    }
  }
}

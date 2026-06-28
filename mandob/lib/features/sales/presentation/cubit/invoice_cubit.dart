import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_invoices.dart';
import '../../domain/repositories/invoice_repository.dart';
import 'invoice_state.dart';

class InvoiceCubit extends Cubit<InvoiceState> {
  final GetInvoices getInvoicesUseCase;
  final InvoiceRepository repository;

  InvoiceCubit({
    required this.getInvoicesUseCase,
    required this.repository,
  }) : super(InvoiceInitial());

  Future<void> loadInvoices({String? date, int? customerId, String? query}) async {
    emit(InvoiceLoading());
    try {
      final invoices = await getInvoicesUseCase(
        date: date,
        customerId: customerId,
        query: query,
      );
      emit(InvoicesLoaded(invoices));
    } catch (e) {
      emit(InvoiceError(e.toString()));
    }
  }

  Future<void> cancelInvoice(int invoiceId) async {
    emit(InvoiceLoading());
    try {
      await repository.cancelInvoice(invoiceId);
      emit(const InvoiceOperationSuccess('تم إلغاء الفاتورة بنجاح وإرجاع المخزون'));
      loadInvoices();
    } catch (e) {
      emit(InvoiceError(e.toString()));
      loadInvoices();
    }
  }
}

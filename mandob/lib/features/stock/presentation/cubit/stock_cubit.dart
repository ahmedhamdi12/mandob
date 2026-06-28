import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/stock_purchase.dart';
import '../../domain/usecases/add_stock_purchase.dart';
import 'stock_state.dart';

class StockCubit extends Cubit<StockState> {
  final AddStockPurchase addStockPurchaseUseCase;

  StockCubit({
    required this.addStockPurchaseUseCase,
  }) : super(StockInitial());

  Future<void> addPurchase(StockPurchase purchase) async {
    emit(StockLoading());
    try {
      await addStockPurchaseUseCase(purchase);
      emit(const StockSuccess('تم إضافة المشتريات للمخزون وتحديث التكلفة بنجاح'));
    } catch (e) {
      emit(StockError(e.toString()));
    }
  }
}

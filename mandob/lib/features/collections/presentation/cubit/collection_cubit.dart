import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/collection.dart';
import '../../domain/usecases/add_collection.dart';
import '../../domain/usecases/get_collections.dart';
import '../../domain/usecases/get_total_debts.dart';
import '../../domain/usecases/get_customer_debt.dart';
import 'collection_state.dart';

class CollectionCubit extends Cubit<CollectionState> {
  final AddCollection addCollectionUseCase;
  final GetCollections getCollectionsUseCase;
  final GetTotalDebts getTotalDebtsUseCase;
  final GetCustomerDebt getCustomerDebtUseCase;

  CollectionCubit({
    required this.addCollectionUseCase,
    required this.getCollectionsUseCase,
    required this.getTotalDebtsUseCase,
    required this.getCustomerDebtUseCase,
  }) : super(CollectionInitial());

  Future<void> loadCollections({String? date, int? customerId}) async {
    emit(CollectionLoading());
    try {
      final collections = await getCollectionsUseCase(date: date, customerId: customerId);
      final totalAmount = collections.fold(0.0, (sum, item) => sum + item.amount);
      emit(CollectionsLoaded(collections: collections, totalAmount: totalAmount));
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }

  Future<void> addCollection(Collection collection) async {
    emit(CollectionLoading());
    try {
      await addCollectionUseCase(collection);
      emit(const CollectionSuccess('تم تسجيل التحصيل بنجاح'));
      loadCollections();
    } catch (e) {
      emit(CollectionError(e.toString()));
    }
  }
}

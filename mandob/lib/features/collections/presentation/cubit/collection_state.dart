import 'package:equatable/equatable.dart';
import '../../domain/entities/collection.dart';

abstract class CollectionState extends Equatable {
  const CollectionState();

  @override
  List<Object> get props => [];
}

class CollectionInitial extends CollectionState {}

class CollectionLoading extends CollectionState {}

class CollectionsLoaded extends CollectionState {
  final List<Collection> collections;
  final double totalAmount;

  const CollectionsLoaded({required this.collections, required this.totalAmount});

  @override
  List<Object> get props => [collections, totalAmount];
}

class CollectionSuccess extends CollectionState {
  final String message;

  const CollectionSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class CollectionError extends CollectionState {
  final String message;

  const CollectionError(this.message);

  @override
  List<Object> get props => [message];
}

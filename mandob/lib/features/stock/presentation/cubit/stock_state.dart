import 'package:equatable/equatable.dart';

abstract class StockState extends Equatable {
  const StockState();

  @override
  List<Object> get props => [];
}

class StockInitial extends StockState {}

class StockLoading extends StockState {}

class StockSuccess extends StockState {
  final String message;

  const StockSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class StockError extends StockState {
  final String message;

  const StockError(this.message);

  @override
  List<Object> get props => [message];
}

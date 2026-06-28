import 'package:equatable/equatable.dart';

class LastPrice extends Equatable {
  final int productId;
  final int customerId;
  final int? unitId;
  final double lastPrice;
  final String updatedAt;

  const LastPrice({
    required this.productId,
    required this.customerId,
    this.unitId,
    required this.lastPrice,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        productId,
        customerId,
        unitId,
        lastPrice,
        updatedAt,
      ];
}

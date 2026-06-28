import 'package:equatable/equatable.dart';

class ProductUnit extends Equatable {
  final int id;
  final int productId;
  final String unitName;
  final int conversionFactor;

  const ProductUnit({
    required this.id,
    required this.productId,
    required this.unitName,
    this.conversionFactor = 1,
  });

  @override
  List<Object?> get props => [id, productId, unitName, conversionFactor];
}

import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String address;
  final double currentBalance;
  final String createdAt;

  const Customer({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.currentBalance = 0.0,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        address,
        currentBalance,
        createdAt,
      ];
}

import 'package:equatable/equatable.dart';

class Supplier extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String address;
  final double currentBalance; // Negative means we owe them (debt), Positive means they owe us
  final String? notes;
  final String createdAt;

  const Supplier({
    required this.id,
    required this.name,
    this.phone = '',
    this.address = '',
    this.currentBalance = 0.0,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        address,
        currentBalance,
        notes,
        createdAt,
      ];
}

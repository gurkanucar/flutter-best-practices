import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({required this.id, required this.name, required this.price});

  final String id;
  final String name;
  final double price;

  /// Demo catalog. A real app loads this from an API or database.
  static const all = [
    Product(id: '1', name: 'Keyboard', price: 1499.9),
    Product(id: '2', name: 'Mouse', price: 749.5),
    Product(id: '3', name: 'Monitor', price: 8999),
  ];

  static Product? findById(String id) => all.where((product) => product.id == id).firstOrNull;

  @override
  List<Object?> get props => [id, name, price];
}

import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
}

class FetchAllProducts extends ProductEvent {
  @override
  List<Object> get props => null;
}

class AddProductEvent extends ProductEvent {
  final int storeId;
  final String productName;
  final double price;
  final int quantity;
  final String expiryDate;

  AddProductEvent({
    this.storeId,
    this.productName,
    this.price,
    this.quantity,
    this.expiryDate,
  });
  @override
  List<Object> get props => null;
}

class FetchProduct extends ProductEvent {
  final int id;

  const FetchProduct({@required this.id}) : assert(id != null);

  @override
  List<Object> get props => [id];
}

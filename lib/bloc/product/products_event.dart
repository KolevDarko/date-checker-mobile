import 'package:equatable/equatable.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
}

class FetchAllProducts extends ProductEvent {
  @override
  List<Object> get props => null;
}

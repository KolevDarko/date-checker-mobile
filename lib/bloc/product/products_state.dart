import 'package:date_checker_app/database/models.dart';
import 'package:meta/meta.dart';
import 'package:equatable/equatable.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductAdded extends ProductState {
  final int productId;

  ProductAdded({this.productId});
}

class ProductEmpty extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final Product product;

  const ProductLoaded({@required this.product}) : assert(product != null);

  @override
  List<Object> get props => [product];
}

class AllProductsLoaded extends ProductState {
  final List<Product> products;

  AllProductsLoaded({this.products});
}

class ProductError extends ProductState {
  final String error;

  ProductError({this.error});
}

import 'package:date_checker_app/bloc/product/products_event.dart';
import 'package:date_checker_app/bloc/product/products_state.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/product_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository productRepository;

  ProductBloc({@required this.productRepository})
      : assert(productRepository != null);

  @override
  ProductState get initialState => ProductEmpty();

  @override
  Stream<ProductState> mapEventToState(ProductEvent event) async* {
    if (event is FetchAllProducts) {
      yield ProductLoading();
      try {
        final List<Product> products = await productRepository.getAllProducts();
        yield AllProductsLoaded(products: products);
      } catch (e) {
        yield ProductError(error: "Грешка при превземање продукти.");
      }
    }
  }
}

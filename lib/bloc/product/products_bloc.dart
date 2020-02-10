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
    print("EVENT $event");
    if (event is FetchProduct) {
      print("fetch product event ${event.id}");
      yield ProductLoading();
      try {
        final Product product = await productRepository.getProduct(event.id);
        yield ProductLoaded(product: product);
      } catch (_) {
        yield ProductError(error: "Something went wrong");
      }
    } else if (event is AddProductEvent) {
      yield ProductLoading();
      try {
        // int productId = await productRepository.addProduct(event.storeId,
        //     event.productName, event.price, event.quantity, event.expiryDate);
        // yield ProductAdded(productId: productId);
      } catch (e) {
        yield ProductError(
            error: "Something went wrong when saving the product.");
      }
    }
  }
}

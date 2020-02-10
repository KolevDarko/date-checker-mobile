import 'package:date_checker_app/bloc/product/products_event.dart';
import 'package:date_checker_app/bloc/product/products_state.dart';
import 'package:date_checker_app/bloc/product_batch/product_batch_event.dart';
import 'package:date_checker_app/bloc/product_batch/product_batch_state.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/product_batch_repository.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductBatchBloc extends Bloc<ProductBatchEvent, ProductBatchState> {
  final ProductBatchRepository productBatchRepository;

  ProductBatchBloc({@required this.productBatchRepository})
      : assert(productBatchRepository != null);

  @override
  ProductBatchState get initialState => ProductBatchEmpty();

  @override
  Stream<ProductBatchState> mapEventToState(ProductBatchEvent event) async* {
    if (event is GetProductBatch) {
      yield ProductBatchLoading();
      try {
        final ProductBatch productBatch =
            await productBatchRepository.getProductBatch(event.id);
        yield ProductBatchLoaded(productBatch: productBatch);
      } catch (_) {
        yield ProductBatchError(error: "Something went wrong");
      }
    } else if (event is AddProductBatch) {
      yield ProductBatchLoading();
      try {
        int productBatchId =
            await productBatchRepository.addProductBatch(event.productBatch);
        yield ProductBatchAdded(productBatchId: productBatchId);
      } catch (e) {
        yield ProductBatchError(
            error: "Something went wrong when saving the product.");
      }
    } else if (event is AllProductBatch) {
      yield ProductBatchLoading();
      try {
        List<ProductBatch> productBatchList =
            await productBatchRepository.allProductBatchList();

        yield AllProductBatchLoaded(productBatchList: productBatchList);
      } catch (e) {
        yield ProductBatchError(
            error: 'Something went wrong. Please try again.');
      }
    }
  }
}

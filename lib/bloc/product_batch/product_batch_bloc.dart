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
            error: "Грешка при зачувување нова пратка. Пробајте повторно.");
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
    } else if (event is OrderByExpiryDateEvent) {
      yield ProductBatchLoading();
      try {
        List<ProductBatch> productBatchList =
            await productBatchRepository.orderedByExpiryDateList();
        yield OrderedByExpiryDate(productBatchList: productBatchList);
      } catch (e) {
        yield ProductBatchError(
            error: 'Something went wrong. Please try again.');
      }
    } else if (event is SyncProductBatchData) {
      yield ProductBatchLoading();
      try {
        String message =
            await this.productBatchRepository.syncProductBatchesData();
        yield SyncProductDataSuccess(message: message);
      } catch (e) {
        yield ProductBatchError(
            error: "Грешка при синхронизација на податоци!");
      }
    } else if (event is UploadProductBatchData) {
      yield ProductBatchLoading();
      try {
        String message =
            await this.productBatchRepository.uploadNewProductBatches();
        yield UploadProductBatchesSuccess(message: message);
      } catch (e) {
        yield ProductBatchError(
            error: "Грешка при снимање податоци на серверот!");
      }
    } else if (event is RemoveProductBatch) {
      try {
        String message =
            await this.productBatchRepository.closeProductBatch(event.warning);
        yield ProductBatchClosedState(message: message);
      } catch (e) {
        yield ProductBatchError(
            error: "Грешка при отстранувањето на пратката.");
      }
    }
  }
}

import 'dart:async';

import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UnsyncedProductBatchBloc
    extends Bloc<UnsyncProductBatchesEvent, UnsyncedProductBachState> {
  final ProductBatchBloc productBatchBloc;
  StreamSubscription productBatchSubscription;

  UnsyncedProductBatchBloc({this.productBatchBloc}) {
    productBatchSubscription = productBatchBloc.listen((state) {
      if (state is AllProductBatchLoaded) {
        add(UnsyncUpdated(unsyncProductBatches: state.productBatchList));
      }
    });
  }

  @override
  UnsyncedProductBachState get initialState {
    return productBatchBloc.state is AllProductBatchLoaded
        ? UnsyncedProductsLoaded(
            unsyncProductBatches: _mapProductBatchToUnsynced(
              (productBatchBloc.state as AllProductBatchLoaded)
                  .productBatchList,
            ),
            unsavedProductBatches: _mapProductBatchToUnsaved(
              (productBatchBloc.state as AllProductBatchLoaded)
                  .productBatchList,
            ),
          )
        : UnsyncedProductsLoading();
  }

  @override
  Stream<UnsyncedProductBachState> mapEventToState(
      UnsyncProductBatchesEvent event) async* {
    if (event is UnsyncUpdated) {
      yield* _mapUnsyncUpdatedToState(event);
    }
  }

  Stream<UnsyncedProductBachState> _mapUnsyncUpdatedToState(
      UnsyncProductBatchesEvent event) async* {
    if (productBatchBloc.state is AllProductBatchLoaded) {
      yield UnsyncedProductsLoaded(
        unsyncProductBatches: _mapProductBatchToUnsynced(
          (productBatchBloc.state as AllProductBatchLoaded).productBatchList,
        ),
        unsavedProductBatches: _mapProductBatchToUnsaved(
          (productBatchBloc.state as AllProductBatchLoaded).productBatchList,
        ),
      );
    }
  }

  List<ProductBatch> _mapProductBatchToUnsynced(
      List<ProductBatch> productBatches) {
    return productBatches
        .where((productBatch) =>
            productBatch.synced == false && productBatch.serverId != null)
        .toList();
  }

  List<ProductBatch> _mapProductBatchToUnsaved(
      List<ProductBatch> productBatches) {
    return productBatches
        .where((productBatch) => productBatch.serverId == null)
        .toList();
  }

  @override
  Future<void> close() {
    print("this 2");
    productBatchSubscription.cancel();
    return super.close();
  }
}

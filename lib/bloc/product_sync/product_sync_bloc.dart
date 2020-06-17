import 'package:date_checker_app/repository/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:date_checker_app/bloc/bloc.dart';

class ProductSyncBloc extends Bloc<ProductSyncEvent, ProductSyncState> {
  final ProductRepository productRepository;
  final ProductBloc productBloc;

  static const NO_NEW_PRODUCTS = 'Нема нови продукти.';
  static const SYNC_SUCCESS = 'Успешно ги синхронизиравте продуктите.';
  static const SYNC_ERROR = 'Грешка при синхронизација на податоци!';

  ProductSyncBloc({this.productRepository, this.productBloc});
  @override
  ProductSyncState get initialState => EmptySyncProductState();

  @override
  Stream<ProductSyncState> mapEventToState(ProductSyncEvent event) async* {
    if (event is SyncProductData) {
      try {
        int productsLength = await this.productRepository.syncProducts();
        if (productsLength == 0) {
          yield SyncProductDataSuccess(message: NO_NEW_PRODUCTS);
        } else {
          yield SyncProductDataSuccess(message: SYNC_SUCCESS);
          productBloc.add(FetchAllProducts());
        }
      } catch (e) {
        yield SyncProductDataError(error: SYNC_ERROR);
      }
    }
  }
}

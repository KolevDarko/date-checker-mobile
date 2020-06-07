import 'package:date_checker_app/repository/product_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:date_checker_app/bloc/bloc.dart';

class ProductSyncBloc extends Bloc<ProductSyncEvent, ProductSyncState> {
  final ProductRepository productRepository;
  final ProductBloc productBloc;

  ProductSyncBloc({this.productRepository, this.productBloc});
  @override
  ProductSyncState get initialState => EmptySyncProductState();

  @override
  Stream<ProductSyncState> mapEventToState(ProductSyncEvent event) async* {
    if (event is SyncProductData) {
      try {
        int productsLength = await this.productRepository.syncProducts();
        if (productsLength == 0) {
          yield SyncProductDataSuccess(message: 'Нема нови продукти.');
        } else {
          yield SyncProductDataSuccess(
              message: 'Успешно ги синхронизиравте продуктите.');
          productBloc.add(FetchAllProducts());
        }
      } catch (e) {
        yield SyncProductDataError(
            error: "Грешка при синхронизација на податоци");
      }
    }
  }
}

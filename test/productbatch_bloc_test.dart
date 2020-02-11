import 'package:bloc_test/bloc_test.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/repository/product_batch_repository.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class ProductBatchRepositoryMock extends Mock
    implements ProductBatchRepository {}

void main() {
  group('ProductBatchBloc', () {
    ProductBatchBloc productBatchBloc;
    ProductBatchRepository productBatchRepository;

    setUp(() {
      productBatchRepository = ProductBatchRepositoryMock();
      productBatchBloc =
          ProductBatchBloc(productBatchRepository: productBatchRepository);
    });

    test('initial state is product batch empty', () {
      expect(productBatchBloc.initialState, ProductBatchEmpty());
    });

    blocTest('loads all the product batches',
        build: () => productBatchBloc,
        act: (bloc) => bloc.add(AllProductBatch()),
        expect: [
          ProductBatchEmpty(),
          ProductBatchLoading(),
          AllProductBatchLoaded(),
        ]);
  });
}

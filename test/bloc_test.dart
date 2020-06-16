import 'package:bloc_test/bloc_test.dart';
import 'package:date_checker_app/bloc/bloc.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/repository/batch_warning_repository.dart';
import 'package:date_checker_app/repository/product_batch_repository.dart';
import 'package:date_checker_app/repository/product_repository.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class ProductBatchRepositoryMock extends Mock
    implements ProductBatchRepository {}

class ProductRepositoryMock extends Mock implements ProductRepository {}

class ProductBatchBlocMock extends Mock implements ProductBatchBloc {}

class ProductBlocMock extends Mock implements ProductBloc {}

class BatchWarningRepositoryMock extends Mock
    implements BatchWarningRepository {}

class SyncBatchWarningBlocMock extends Mock implements SyncBatchWarningBloc {}

class ProductSyncBlocMock extends Mock implements ProductSyncBloc {}

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
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

    blocTest(
      'loads all the product batches',
      build: () async => productBatchBloc,
      act: (bloc) => bloc.add(AllProductBatch()),
      expect: [
        ProductBatchEmpty(),
        ProductBatchLoading(),
        AllProductBatchLoaded(),
      ],
    );

    blocTest(
      'synchronize product batch data',
      build: () async => productBatchBloc,
      act: (bloc) => bloc.add(SyncProductBatchData()),
      expect: [
        ProductBatchEmpty(),
        ProductBatchLoading(),
        SyncProductBatchDataSuccess(),
      ],
    );

    blocTest(
      'order by expiry date',
      build: () async => productBatchBloc,
      act: (bloc) => bloc.add(OrderByExpiryDateEvent()),
      expect: [
        ProductBatchEmpty(),
        ProductBatchLoading(),
        OrderedByExpiryDate(),
      ],
    );

    blocTest(
      'add product batch',
      build: () async => productBatchBloc,
      act: (bloc) => bloc.add(AddProductBatch()),
      expect: [
        ProductBatchEmpty(),
        ProductBatchLoading(),
        ProductBatchAdded(),
      ],
    );

    tearDown(() {
      productBatchBloc?.close();
    });
  });
  group('ProductBloc', () {
    ProductBloc productBloc;
    ProductRepository productRepository;

    setUp(() {
      productRepository = ProductRepositoryMock();
      productBloc = ProductBloc(productRepository: productRepository);
    });

    test('initial state is ProductEmpty', () {
      expect(productBloc.initialState, ProductEmpty());
    });

    blocTest(
      'get all products',
      build: () async => productBloc,
      act: (bloc) => bloc.add(FetchAllProducts()),
      expect: [
        ProductEmpty(),
        ProductLoading(),
        AllProductsLoaded(),
      ],
    );
    tearDown(() {
      productBloc?.close();
    });
  });

  group('BatchWarningBloc', () {
    BatchWarningBloc batchWarningBloc;
    BatchWarningRepository batchWarningRepository;
    ProductBatchBloc productBatchBloc;
    BatchWarning batchWarning;
    setUp(() {
      batchWarningRepository = BatchWarningRepositoryMock();
      productBatchBloc = ProductBatchBlocMock();
      batchWarningBloc = BatchWarningBloc(
        batchWarningRepository: batchWarningRepository,
        productBatchBloc: productBatchBloc,
      );
      batchWarning = BatchWarning(
        1,
        'Product 1',
        20,
        "${DateTime.parse('2020-03-08')}",
        1,
        BatchWarning.batchWarningStatus()[0],
        BatchWarning.batchWarningPriority()[0],
        30,
        30,
        "${DateTime.now()}",
      );
    });

    test('initial state is ProductEmpty', () {
      expect(batchWarningBloc.initialState, BatchWarningEmpty());
    });

    blocTest(
      'get all batch warnings',
      build: () async => batchWarningBloc,
      act: (bloc) => bloc.add(AllBatchWarnings()),
      expect: [
        BatchWarningEmpty(),
        BatchWarningLoading(),
        BatchWarningAllLoaded(),
      ],
    );
    blocTest(
      'edit quantity',
      build: () async => batchWarningBloc,
      act: (bloc) =>
          bloc.add(EditQuantityEvent(quantity: 20, batchWarning: batchWarning)),
      expect: [
        BatchWarningEmpty(),
        Success(),
      ],
    );

    tearDown(() {
      productBatchBloc?.close();
      batchWarningBloc?.close();
    });
  });
}

import 'package:date_checker_app/database/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('updateQuantity function tests', () {
    ProductBatch batch;
    setUp(() {
      batch = ProductBatch(1, 1, "1001", 1, 30, "2020-06-30", false,
          "2020-06-15 21:11:14.208683", "2020-06-15 21:11:14.208683", 'Fanta');
    });
    test('product batch updateQuantity test', () {
      String dt = DateTime.now().toString();
      int quantity = 120;

      batch.updateQuantity(
        quantity: quantity,
        dtString: dt,
      );
      expect(batch.updated, dt);
      expect(batch.quantity, quantity);
    });
    test('product batch updateQuantity test with no update date time ', () {
      String dt = DateTime.now().toString();
      int quantity = 120;

      batch.updateQuantity(
        quantity: quantity,
      );

      expect(batch.updated, isNot(dt));
      expect(batch.quantity, quantity);
    });
  });
}

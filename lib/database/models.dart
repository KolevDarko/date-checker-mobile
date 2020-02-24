import 'package:date_checker_app/database/database.dart';
import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';

@entity
class Product {
  @PrimaryKey(autoGenerate: true)
  int id;

  String name;
  double price;
  String barCode;

  Product(this.id, this.name, this.price, this.barCode);

  @override
  String toString() {
    return "$name - $barCode";
  }

  // @override
  // List<Object> get props => [id, name, price];

}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['productId'],
    parentColumns: ['id'],
    entity: Product,
  )
])
class ProductBatch {
  @PrimaryKey(autoGenerate: true)
  int id;

  String barCode;
  int productId;
  int quantity;
  String expirationDate;

  String created;
  String updated;

  ProductBatch(
      this.id, this.barCode, this.productId, this.quantity, this.expirationDate,
      [this.created, this.updated]);

  @override
  String toString() {
    return "Product Batch $barCode, expDate: $expirationDate";
  }

  DateTime returnDateTimeExpDate() {
    return DateTime.parse(this.expirationDate);
  }

  String formatDateTime() {
    return '${this.returnDateTimeExpDate().day}/${this.returnDateTimeExpDate().month}/${this.returnDateTimeExpDate().year.remainder(100)}';
  }
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['productBatchId'],
    parentColumns: ['barCode'],
    entity: ProductBatch,
  )
])
class BatchWarning {
  @PrimaryKey(autoGenerate: true)
  int id;

  int productBatchId;
  String status;
  String priority;
  int oldQuantity;
  int newQuantity;
  String created;
  String updated;

  BatchWarning(this.id, this.productBatchId, this.status, this.priority,
      this.oldQuantity, this.newQuantity, this.created,
      [this.updated]);

  static List<String> batchWarningStatus() {
    return ['NEW', 'CHECKED'];
  }

  static List<String> batchWarningPriority() {
    return ['WARNING', 'EXPIRED'];
  }

  static createBatchWarningInstance(AppDatabase database, int productBatchId,
      int oldQuantity, int newQuantity) async {
    BatchWarning batchWarning = BatchWarning(
        null,
        productBatchId,
        batchWarningStatus()[0],
        batchWarningPriority()[0],
        oldQuantity,
        newQuantity,
        "${DateTime.now()}");
    await database.batchWarningDao.add(batchWarning);
  }
}

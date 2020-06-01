import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

@entity
class Product {
  @PrimaryKey(autoGenerate: true)
  int id;
  int serverId;
  String name;
  double price;
  String barCode;

  Product(this.id, this.serverId, this.name, this.price, this.barCode);

  @override
  String toString() {
    return "$name - $barCode,  id: $id";
  }

  static Product fromJson(dynamic json) {
    return Product(
      null,
      json['id'],
      json['name'],
      json['price'],
      json['id_code'],
    );
  }
}

@entity
class ProductBatch {
  @PrimaryKey(autoGenerate: true)
  int id;

  int serverId;
  String barCode;
  int productId;
  int quantity;
  String expirationDate;
  String productName;

  bool synced;
  String created;
  String updated;

  ProductBatch(
    this.id,
    this.serverId,
    this.barCode,
    this.productId,
    this.quantity,
    this.expirationDate,
    this.synced, [
    this.created,
    this.updated,
    this.productName,
  ]);

  @override
  String toString() {
    return "Product Batch $barCode, expDate: $expirationDate, serverId: $serverId";
  }

  DateTime returnDateTimeExpDate() {
    return DateTime.parse(this.expirationDate);
  }

  DateTime returnDateTimeUpdated() {
    return DateTime.parse(this.updated);
  }

  String formatDateTime({bool shortYear = true}) {
    if (!shortYear) {
      return '${this.returnDateTimeExpDate().day}/${this.returnDateTimeExpDate().month}/${this.returnDateTimeExpDate().year}';
    }
    return '${this.returnDateTimeExpDate().day}/${this.returnDateTimeExpDate().month}/${this.returnDateTimeExpDate().year.remainder(100)}';
  }

  static ProductBatch fromJson(dynamic json) {
    return ProductBatch(
      null,
      json['id'],
      json['id_code'],
      json['product']['id'],
      json['quantity'],
      json['expiration_date'],
      true,
      DateTime.parse(json['created_on']).toString(),
      DateTime.parse(json['updated_on']).toString(),
      json['product']['name'],
    );
  }

  static Map<String, dynamic> toJson(ProductBatch productBatch) =>
      <String, dynamic>{
        "id": productBatch.id,
        "serverId": productBatch.serverId,
        "barCode": productBatch.barCode,
        "productId": productBatch.productId,
        "quantity": productBatch.quantity,
        "expirationDate": productBatch.expirationDate,
        "created": productBatch.created,
        "updated": productBatch.updated,
      };

  static List<Map<String, dynamic>> toJsonList(
      List<ProductBatch> productBatches) {
    return productBatches.map((elem) => toJson(elem)).toList();
  }
}

@entity
class BatchWarning {
  @PrimaryKey(autoGenerate: true)
  int id;

  // od api doagja product name i denovi pred istek
  String productName;
  int daysLeft;
  String expirationDate;
  int productBatchId;
  String status;
  String priority;
  int oldQuantity;
  int newQuantity;

  String created;
  String updated;

  BatchWarning(
      this.id,
      this.productName,
      this.daysLeft,
      this.expirationDate,
      this.productBatchId,
      this.status,
      this.priority,
      this.oldQuantity,
      this.newQuantity,
      this.created,
      [this.updated]);

  static List<String> batchWarningStatus() {
    return ['NEW', 'CHECKED'];
  }

  static List<String> batchWarningPriority() {
    return ['WARNING', 'EXPIRED'];
  }

  MaterialColor priorityColor() {
    if (this.priority == 'WARNING') {
      return Colors.yellow;
    } else if (this.priority == 'EXPIRED') {
      return Colors.red;
    }
  }

  static BatchWarning fromJson(dynamic json) {
    return BatchWarning(
      json['id'],
      json['product_name'],
      json['days_left'],
      json['expiration_date'],
      json['product_batch_id'],
      batchWarningStatus()[0],
      json['priority'],
      json['quantity'],
      json['quantity'],
      "${DateTime.now()}",
      "${DateTime.now()}",
    );
  }

  static Map<String, dynamic> toJson(BatchWarning warning) {
    return {
      'id': warning.id,
      'quantity': warning.newQuantity,
      'productBatchId': warning.productBatchId,
    };
  }

  static Map<String, List<dynamic>> toJsonMap(List<BatchWarning> warnings) {
    List<dynamic> jsonWarnings =
        warnings.map((warning) => toJson(warning)).toList();
    return {'batchWarnings': jsonWarnings};
  }

  @override
  String toString() {
    return "$productName - $oldQuantity - $expirationDate";
  }
}

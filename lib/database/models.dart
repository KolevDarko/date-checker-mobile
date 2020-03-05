import 'package:date_checker_app/database/database.dart';
import 'package:equatable/equatable.dart';
import 'package:floor/floor.dart';
import 'package:flutter/material.dart';

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

  static Product fromJson(dynamic json) {
    return Product(
      null,
      json['name'],
      json['price'],
      json['barCode'],
    );
  }
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

  static ProductBatch fromJson(dynamic json) {
    return ProductBatch(
      null,
      json['barCode'],
      json['productId'],
      json['quantity'],
      json['expirationDate'],
      "${DateTime.now()}",
      "${DateTime.now()}",
    );
  }
}

@Entity(foreignKeys: [
  ForeignKey(
    childColumns: ['productBatchId'],
    parentColumns: ['id'],
    entity: ProductBatch,
  )
])
class BatchWarning {
  @PrimaryKey(autoGenerate: true)
  int id;

  // od api doagja product name i denovi pred istek
  String productName;
  int daysLeft;
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

  static createBatchWarningInstance(
    AppDatabase database,
    String productName,
    int daysLeft,
    int productBatchId,
  ) async {
    ProductBatch batch = await database.productBatchDao.get(productBatchId);
    String priority;
    if (daysLeft < 0) {
      priority = batchWarningPriority()[1];
    } else {
      priority = batchWarningPriority()[0];
    }

    BatchWarning batchWarning = BatchWarning(
      null,
      productName,
      daysLeft,
      productBatchId,
      batchWarningStatus()[0],
      priority,
      null,
      null,
      "${DateTime.now()}",
      "${DateTime.now()}",
    );
    batchWarning.oldQuantity = batch.quantity;
    batchWarning.newQuantity = batch.quantity;
    await database.batchWarningDao.add(batchWarning);
  }

  static BatchWarning fromJson(dynamic json) {
    return BatchWarning(
      json['id'],
      json['product_name'],
      json['days_left'],
      json['product_batch_id'],
      batchWarningStatus()[0],
      json['priority'],
      json['quantity'],
      json['quantity'],
      "${DateTime.now()}",
      "${DateTime.now()}",
    );
  }
}

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

  static List<Product> productsListFromJson(dynamic productsJson) {
    return productsJson
        .map<Product>((productJson) => Product.fromJson((productJson)))
        .toList();
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

  static List<ProductBatch> batchesListFromJson(dynamic productBatchesJson) {
    return productBatchesJson
        .map<ProductBatch>(
            (productBatchJson) => ProductBatch.fromJson(productBatchJson))
        .toList();
  }

  void updateQuantity({@required int quantity, @required String dtString}) {
    this.quantity = quantity ?? this.quantity;
    this.updated = dtString ?? this.updated;
    this.synced = false;
  }

  ProductBatch copyWith({
    int id,
    int serverId,
    String barCode,
    int productId,
    int quantity,
    String expirationDate,
    String productName,
    bool synced,
    String created,
    String updated,
  }) {
    return ProductBatch(
      id ?? this.id,
      serverId ?? this.serverId,
      barCode ?? this.barCode,
      productId ?? this.productId,
      quantity ?? this.quantity,
      expirationDate ?? this.expirationDate,
      synced ?? this.synced,
      created ?? this.created,
      updated ?? this.updated,
      productName ?? this.productName,
    );
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

  static List<BatchWarning> warningsListFromJson(dynamic batchWarningsJson) {
    return batchWarningsJson
        .map<BatchWarning>((warning) => BatchWarning.fromJson(warning))
        .toList();
  }

  @override
  String toString() {
    return "$productName - $oldQuantity - $expirationDate";
  }

  void updateQuantity({@required int quantity, @required String dtString}) {
    this.newQuantity = quantity ?? this.newQuantity;
    this.updated = dtString ?? this.updated;
    this.status = 'CHECKED';
  }

  BatchWarning copyWith({
    int id,
    String productName,
    int daysLeft,
    String expirationDate,
    int productBatchId,
    String status,
    String priority,
    int oldQuantity,
    int newQuantity,
    String created,
    String updated,
  }) {
    return BatchWarning(
      id ?? this.id,
      productName ?? this.productName,
      daysLeft ?? this.daysLeft,
      expirationDate ?? this.expirationDate,
      productBatchId ?? this.productBatchId,
      status ?? this.status,
      priority ?? this.priority,
      oldQuantity ?? this.oldQuantity,
      newQuantity ?? this.newQuantity,
      created ?? this.created,
      updated ?? this.updated,
    );
  }
}

@entity
class User {
  @PrimaryKey(autoGenerate: true)
  int id;
  String email;
  String password;
  String firstName;
  String lastName;
  User(
    this.id,
    this.email,
    this.password, [
    this.firstName,
    this.lastName,
  ]);

  @override
  String toString() {
    return "User email: $email";
  }
}

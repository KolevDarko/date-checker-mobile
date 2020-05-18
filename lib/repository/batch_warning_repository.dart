import 'dart:io';

import 'package:date_checker_app/api/batch_warning_client.dart';
import 'package:date_checker_app/database/database.dart';
import 'package:date_checker_app/database/models.dart';
import 'package:date_checker_app/database/provider.dart';

class BatchWarningRepository {
  final BatchWarningApiClient batchWarningApi;
  final AppDatabase db;

  BatchWarningRepository({this.db, this.batchWarningApi});

  Future<List<BatchWarning>> warnings() async {
    return this.db.batchWarningDao.allStatusChecked('NEW');
  }

  Future<void> updateQuantity(int quantity, BatchWarning batchWarning) async {
    AppDatabase db = await DbProvider.instance.database;
    batchWarning.newQuantity = quantity;
    batchWarning.status = 'CHECKED';
    ProductBatch productBatch =
        await db.productBatchDao.get(batchWarning.productBatchId);
    productBatch.quantity = quantity;
    await db.productBatchDao.updateProductBatch(productBatch);
    await db.batchWarningDao.updateBatchWarning(batchWarning);
    // check if we have internet connection
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        await batchWarningApi.updateQuantity(quantity, batchWarning);
      }
    } on SocketException catch (_) {
      print('not connected');
    }
  }

  Future<List<BatchWarning>> syncWarnings() async {
    BatchWarning batchWarning;
    List<BatchWarning> warnings = [];
    try {
      batchWarning = await this.db.batchWarningDao.getLast();
    } catch (e) {
      batchWarning = null;
    }
    if (batchWarning != null) {
      warnings = await this.batchWarningApi.refreshWarnings(batchWarning.id);
    } else {
      warnings = await this.batchWarningApi.getAllBatchWarnings();
    }

    if (warnings.length > 0) {
      this.saveWarningsLocally(warnings);
    }
  }

  Future<void> saveWarningsLocally(List<BatchWarning> newWarnings) async {
    try {
      await this.db.batchWarningDao.saveWarnings(newWarnings);
    } catch (e) {
      print("here error when saving warnings from http, $e");
      throw Exception("Error saving Batch Warnings to database.");
    }
  }
}

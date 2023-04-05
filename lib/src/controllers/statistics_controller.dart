import 'package:collection/collection.dart';
import 'package:flukki_product_tours/src/controllers/test_product_tour_controller.dart';

import '../api/flukki_api.dart';
import '../helpers/user_controller.dart';
import '../models/product_tour_model.dart';
import 'flukki_controller.dart';
import 'product_tours_controller.dart';

class StatisticsController {
  static final StatisticsController instance = StatisticsController._();
  List<ProductTourProgress> _statistics = [];

  StatisticsController._();

  bool isProductTourFinished(ProductTour productTour) {
    if (productTour.id == null ||
        FlukkiController.instance.isInBuilderTestMode) {
      return TestStatsController.currentIndex >= productTour.stepsCount ||
          TestStatsController.skippedIndex != null;
    }
    final productTourProgress = _statistics
        .firstWhereOrNull((element) => element.productTourId == productTour.id);
    if (productTourProgress == null) return false;

    return productTourProgress.currentStep >= productTour.stepsCount ||
        productTourProgress.skippedIndex != null;
  }

  int getCurrentStepIndex(ProductTour productTour) {
    if (productTour.id == null ||
        FlukkiController.instance.isInBuilderTestMode) {
      return TestStatsController.currentIndex;
    }
    final productTourProgress = _statistics
        .firstWhereOrNull((element) => element.productTourId == productTour.id);
    if (productTourProgress == null) return 0;
    return productTourProgress.currentStep;
  }

  int? getSkippedIndex(ProductTour productTour) {
    if (productTour.id == null ||
        FlukkiController.instance.isInBuilderTestMode) {
      return TestStatsController.skippedIndex;
    }
    final productTourProgress = _statistics
        .firstWhereOrNull((element) => element.productTourId == productTour.id);
    if (productTourProgress == null) {
      return null;
    }
    return productTourProgress.skippedIndex;
  }

  Future<void> fetchStatistics() async {
    if (FlukkiController.instance.isInBuilderTestMode) return;
    final appName = FlukkiController.instance.appId;
    final apiKey = FlukkiController.instance.apiKey!;
    final userID = UserController.instance.userID;
    final productTourIDs = ProductToursController.instance.productTours
        .where((element) => element.id != null)
        .map((e) => e.id!)
        .toList();
    if (appName != null && userID != null) {
      final stats = await FlukkiApi.fetchStatistics(
          apiKey: apiKey,
          appName: appName,
          userID: userID,
          productTourIDs: productTourIDs);
      if (stats != null) {
        _statistics = stats;
      }
    }
  }

  Future<void> sendStatistics({ProductTour? productTour}) async {
    if (FlukkiController.instance.isInBuilderTestMode) return;
    final appName = FlukkiController.instance.appId;
    final apiKey = FlukkiController.instance.apiKey!;
    final userID = UserController.instance.userID;
    final List<ProductTour> productTours = [];
    if (productTour != null) {
      productTours.add(productTour);
    } else {
      productTours.addAll(ProductToursController.instance.productTours);
    }
    final statistics = productTours
        .where((element) => element.id != null)
        .map((productTour) => _statistics
            .firstWhere((element) => element.productTourId == productTour.id))
        .toList();

    if (appName != null && userID != null) {
      await FlukkiApi.sendStatistics(
          apiKey: apiKey,
          appName: appName,
          userID: userID,
          statistics: statistics);
    }
  }

  ProductTourProgress getProgress(ProductTour productTour) {
    final productTourProgress = _statistics
        .firstWhereOrNull((element) => element.productTourId == productTour.id);
    if (productTourProgress == null) {
      return ProductTourProgress(
          productTourId: productTour.id!, appName: productTour.appName ?? '');
    }
    return productTourProgress;
  }

  void updateProgressCurrent(
      {required ProductTour productTour, required int progress}) {
    if (FlukkiController.instance.isInBuilderTestMode) {
      TestStatsController.currentIndex += progress;
      return;
    }
    final productTourProgress = _statistics
        .firstWhereOrNull((element) => element.productTourId == productTour.id);
    if (productTourProgress == null) {
      _statistics.add(ProductTourProgress(
          productTourId: productTour.id!,
          appName: FlukkiController.instance.appId ?? '')
        ..currentStep = progress);
    } else {
      productTourProgress.currentStep += progress;
    }
  }

  void updateProgressSkip(
      {required ProductTour productTour, required int skipIndex}) {
    if (FlukkiController.instance.isInBuilderTestMode) {
      TestStatsController.skippedIndex = skipIndex;
      return;
    }
    final productTourProgress = _statistics
        .firstWhereOrNull((element) => element.productTourId == productTour.id);
    if (productTourProgress == null) {
      _statistics.add(ProductTourProgress(
          productTourId: productTour.id!,
          appName: FlukkiController.instance.appId ?? '')
        ..skippedIndex = skipIndex);
    } else {
      productTourProgress.skippedIndex = skipIndex;
    }
  }

  clear() => _statistics.clear();
}

class ProductTourProgress {
  int currentStep;
  int? skippedIndex;
  String productTourId;
  String? appName;

  ProductTourProgress({required this.productTourId, required this.appName})
      : currentStep = 0;

  Map<String, dynamic> toJson() => {
        'currentStep': currentStep,
        'skippedIndex': skippedIndex,
        'productTourId': productTourId,
        'appName': appName,
      };

  ProductTourProgress.fromJson(Map<String, dynamic> json)
      : currentStep = json['currentStep'],
        skippedIndex = json['skippedIndex'],
        productTourId = json['productTourId'],
        appName = json['appName'];
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:collection/collection.dart';

import '../api/flukki_api.dart';
import '../../constants.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';
import 'local_storage_controller.dart';
import 'statistics_controller.dart';

class ProductToursController {
  static final ProductToursController instance = ProductToursController._();

  List<ProductTour> _productTours = [];
  bool isStepDisplayed = false;
  bool isLoading = false;

  ProductToursController._();

  List<ProductTour> get productTours => _productTours;

  Future<void> initialize(
      Map<String, void Function()> callbacks, String? deviceID) async {
    isLoading = true;
    List<ProductTour>? remoteProductTours =
        await FlukkiApi.fetchProductTours(deviceId: deviceID);

    final sharedPreferences = await SharedPreferences.getInstance();

    var localProductTours = (sharedPreferences
                .getStringList(FlukkiContants.productToursPreferencesKey) ??
            [])
        .map((e) => ProductTour.fromJson(jsonDecode(e), callbacks))
        .toList();

    if (remoteProductTours != null) {
      remoteProductTours = remoteProductTours.map((remoteProductTour) {
        ProductTour? matchingLocalCopy = localProductTours.firstWhereOrNull(
            (localProductTour) => localProductTour.id == remoteProductTour.id);
        if (matchingLocalCopy != null) {
          remoteProductTour.currentIndex = matchingLocalCopy.currentIndex;
          remoteProductTour.skippedIndex = matchingLocalCopy.skippedIndex;
        }
        return remoteProductTour;
      }).toList();
      await sharedPreferences.setStringList(
          FlukkiContants.productToursPreferencesKey,
          remoteProductTours.map((e) => jsonEncode(e.toJson())).toList());
      _productTours = remoteProductTours;
    } else if (remoteProductTours == null && localProductTours.isNotEmpty) {
      _productTours = localProductTours;
    } else if (remoteProductTours == null && localProductTours.isEmpty) {
      _productTours = [];
    }
    isLoading = false;
  }

  ProductTour? findMatchingProductTourStep(List<String> widgetTree) {
    final matchingProductTours = _productTours.where((productTour) =>
        productTour.hasMatchingProductTourSteps(widgetTree) &&
        !productTour.isFinished);
    if (matchingProductTours.isEmpty) {
      return null;
    }
    return matchingProductTours.first;
  }

  List<ProductTour> findActivePointerProductTours() {
    return _productTours
        .where((productTour) =>
            productTour.currentStep is PointerProductTourStep &&
            !productTour.isFinished)
        .toList();
  }

  bool shouldCheckThisWidget(String widgetName) {
    final matchingProductTours = _productTours.where((productTour) =>
        productTour.hasStepForTheWidget(widgetName) && !productTour.isFinished);
    return matchingProductTours.isNotEmpty;
  }

  ProductTour? isAnnouncementProductTourActive() =>
      _productTours.firstWhereOrNull(
          (element) => element.currentStep is AnnouncementProductTourStep);

  Future<void> madeProgress(ProductTour productTour,
      {bool isAnnouncement = false, required bool isTestMode}) async {
    if (isAnnouncement) {
      final currentStep = productTour.steps[productTour.currentIndex]
          as AnnouncementProductTourStep;
      var progress = 1;
      for (int i = productTour.currentIndex + 1;
          i < productTour.stepsCount;
          i++) {
        final compareStep = productTour.steps[i];
        if (compareStep is AnnouncementProductTourStep &&
            compareStep.displayStyle == currentStep.displayStyle) {
          progress++;
        } else {
          break;
        }
      }
      productTour.currentIndex += progress;
    } else {
      productTour.currentIndex++;
    }
    await LocalStorageController.saveProductTour(productTour);
    if (!isTestMode) {
      StatisticsController.instance.sendStatistics(productTour: productTour);
    }
  }

  void replaceProductTour(ProductTour productTour) {
    final index =
        _productTours.indexWhere((element) => element.id == productTour.id);
    if (index == -1) {
      _productTours.add(productTour);
    } else {
      _productTours.removeAt(index);
      _productTours.insert(index, productTour);
    }
  }

  Future<void> removeProductTour(ProductTour productTour) async {
    await FlukkiApi.removeProductTour(productTour);
    _productTours.removeWhere((element) => element.id == productTour.id);
  }

  Future<void> skipAll(ProductTour productTour) async {
    productTour.skippedIndex = productTour.currentIndex;
    await LocalStorageController.saveProductTour(productTour);
    await StatisticsController.instance
        .sendStatistics(productTour: productTour);
  }
}

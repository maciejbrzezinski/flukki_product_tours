import 'dart:convert';

import 'package:flukki_product_tours/src/helpers/app_version_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:collection/collection.dart';

import '../api/flukki_api.dart';
import '../../constants.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';
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
    await AppVersionController.instance.init();
    List<ProductTour>? remoteProductTours =
        await FlukkiApi.fetchProductTours(deviceId: deviceID);

    final sharedPreferences = await SharedPreferences.getInstance();

    var localProductTours = (sharedPreferences
                .getStringList(FlukkiConstants.productToursPreferencesKey) ??
            [])
        .map((e) => ProductTour.fromJson(jsonDecode(e), callbacks))
        .toList();

    if (remoteProductTours != null) {
      await sharedPreferences.setStringList(
          FlukkiConstants.productToursPreferencesKey,
          remoteProductTours.map((e) => jsonEncode(e.toJson())).toList());
      _productTours = remoteProductTours;
    } else if (remoteProductTours == null && localProductTours.isNotEmpty) {
      _productTours = localProductTours;
    } else if (remoteProductTours == null && localProductTours.isEmpty) {
      _productTours = [];
    }
    isLoading = false;
  }

  List<ProductTour> findActivePointerProductTours() {
    return _productTours
        .where((productTour) =>
            productTour.currentStep is PointerProductTourStep &&
            !productTour.isFinished)
        .toList();
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
      StatisticsController.instance
          .updateProgressCurrent(productTour: productTour, progress: progress);
    } else {
      StatisticsController.instance
          .updateProgressCurrent(productTour: productTour, progress: 1);
    }
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
    StatisticsController.instance.updateProgressSkip(
        productTour: productTour, skipIndex: productTour.currentIndex);
    await StatisticsController.instance
        .sendStatistics(productTour: productTour);
  }
}

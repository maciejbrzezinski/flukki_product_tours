import '../api/flukki_api.dart';
import '../helpers/device_id_controller.dart';
import '../models/product_tour_model.dart';
import 'flukki_controller.dart';
import 'product_tours_controller.dart';

class StatisticsController {
  static final StatisticsController instance = StatisticsController._();

  StatisticsController._();

  Future<void> sendStatistics({ProductTour? productTour}) async {
    final appName = FlukkiController.instance.appId;
    final apiKey = FlukkiController.instance.apiKey!;
    final device = DeviceIdController.instance.deviceId;
    final List<ProductTour> productTours = [];
    if (productTour != null) {
      productTours.add(productTour);
    } else {
      productTours.addAll(ProductToursController.instance.productTours);
    }
    final statistics = productTours
        .map((productTour) => ProductTourProgress.fromProductTour(productTour))
        .toList();

    if (appName != null && device != null) {
      await FlukkiApi.sendStatistics(
          apiKey: apiKey,
          appName: appName,
          deviceId: device,
          statistics: statistics);
    }
  }
}

class ProductTourProgress {
  int currentStep;
  int? skippedIndex;
  String productTourId;
  String? appName;

  ProductTourProgress.fromProductTour(ProductTour productTour)
      : currentStep = productTour.currentIndex,
        skippedIndex = productTour.skippedIndex,
        productTourId = productTour.id!,
        appName = productTour.appName;

  Map<String, dynamic> toJson() => {
        'currentStep': currentStep,
        'skippedIndex': skippedIndex,
        'productTourId': productTourId
      };
}

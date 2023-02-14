import '../controllers/flukki_controller.dart';
import '../controllers/product_tours_controller.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';

class ProductTourMatcher {
  static ProductTour? getMatchingProductTour(
      List<String> widgetTree, int widgetIndex) {
    ProductTour? matchingProductTour;
    if (FlukkiController.instance.isInBuilderTestMode) {
      final testController =
          FlukkiController.instance.testProductTourController;
      matchingProductTour = testController!.productTour;
      if (matchingProductTour.currentIndex >= matchingProductTour.stepsCount ||
          matchingProductTour.skippedIndex != null) {
        matchingProductTour.currentIndex = 0;
        matchingProductTour.skippedIndex = null;
      }
      if (matchingProductTour.hasMatchingProductTourSteps(
          widgetTree, widgetIndex)) {
        return matchingProductTour;
      } else {
        return null;
      }
    } else {
      matchingProductTour = ProductToursController.instance
          .findMatchingProductTourStep(widgetTree, widgetIndex);
    }
    return matchingProductTour;
  }

  static bool shouldCheckThisWidget(String widgetName) {
    bool result = false;
    if (FlukkiController.instance.isInBuilderTestMode) {
      final testController =
          FlukkiController.instance.testProductTourController;
      final matchingProductTour = testController!.productTour;
      if (matchingProductTour.currentIndex >= matchingProductTour.stepsCount ||
          matchingProductTour.skippedIndex != null) {
        matchingProductTour.currentIndex = 0;
        matchingProductTour.skippedIndex = null;
      }
      final currentStep = matchingProductTour.currentStep;
      if (currentStep is PointerProductTourStep) {
        return currentStep.widgetKey.startsWith('[$widgetName');
      }
    } else {
      return ProductToursController.instance.shouldCheckThisWidget(widgetName);
    }
    return result;
  }

  static ProductTour? getAnnouncementProductTour() {
    if (FlukkiController.instance.isInBuilderTestMode) {
      final testController =
          FlukkiController.instance.testProductTourController;
      final matchingProductTour = testController!.productTour;
      if (matchingProductTour.currentIndex >= matchingProductTour.stepsCount ||
          matchingProductTour.skippedIndex != null) {
        matchingProductTour.currentIndex = 0;
        matchingProductTour.skippedIndex = null;
      }
      final currentStep = matchingProductTour.currentStep;
      if (currentStep is AnnouncementProductTourStep) {
        return matchingProductTour;
      }
    } else {
      return ProductToursController.instance.isAnnouncementProductTourActive();
    }
    return null;
  }
}

import 'package:flutter/material.dart';

import '../controllers/flukki_controller.dart';
import '../controllers/product_tours_controller.dart';
import '../controllers/test_product_tour_controller.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';
import '../widgets/recognizable_wrapper.dart';

class ProductTourMatcher {
  static ProductTour? getAnnouncementProductTour() {
    if (FlukkiController.instance.isInBuilderTestMode) {
      final testController =
          FlukkiController.instance.testProductTourController;
      final matchingProductTour = testController!.productTour;
      if (matchingProductTour.currentIndex >= matchingProductTour.stepsCount ||
          matchingProductTour.skippedIndex != null) {
        TestStatsController.currentIndex = 0;
        TestStatsController.skippedIndex = null;
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

  static String cropWidgetName(Element element) {
    var widgetName = element.widget.runtimeType.toString();
    final parametersIndex = widgetName.indexOf('(');
    if (parametersIndex != -1) {
      widgetName = widgetName.substring(0, parametersIndex);
    }
    final hashIndex = widgetName.indexOf('#');
    if (hashIndex != -1) {
      widgetName = widgetName.substring(0, hashIndex);
    }
    return widgetName;
  }

  static bool ancestorVisitor(Element element, List<String> ancestors) {
    if (element.widget is MyRecognizableWrapper) {
      return false;
    }
    ancestors.add(cropWidgetName(element));
    return true;
  }

  static List<ProductTour> getProductToursWithCurrentPointer() {
    List<ProductTour> matchingProductTours = [];
    if (FlukkiController.instance.isInBuilderTestMode) {
      final testController =
          FlukkiController.instance.testProductTourController;
      final testProductTour = testController!.productTour;
      matchingProductTours.add(testProductTour);
      if (testProductTour.currentIndex >= testProductTour.stepsCount ||
          testProductTour.skippedIndex != null) {
        TestStatsController.currentIndex = 0;
        TestStatsController.skippedIndex = null;
      }
      if (testProductTour.currentStep is PointerProductTourStep) {
        return matchingProductTours;
      } else {
        return [];
      }
    } else {
      matchingProductTours =
          ProductToursController.instance.findActivePointerProductTours();
    }
    return matchingProductTours;
  }
}

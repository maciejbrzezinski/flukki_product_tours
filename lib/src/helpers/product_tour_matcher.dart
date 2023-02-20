import 'package:flutter/material.dart';

import '../controllers/flukki_controller.dart';
import '../controllers/product_tours_controller.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';

class ProductTourMatcher {
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

  static String cropWidgetName(String widgetName) {
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

  static bool ancestorVisitor(Element e, List<String> ancestors) {
    final widgetName = cropWidgetName(e.widget.toString());
    if (widgetName.contains('MyRecognizableWrapper')) {
      return false;
    }
    ancestors.add(cropWidgetName(e.widget.toString()));
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
        testProductTour.currentIndex = 0;
        testProductTour.skippedIndex = null;
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

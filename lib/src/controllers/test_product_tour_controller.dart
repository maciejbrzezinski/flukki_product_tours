import '../models/product_tour_model.dart';

class TestProductTourController {
  ProductTour productTour;

  TestProductTourController(this.productTour) {
    TestStatsController.currentIndex = 0;
    TestStatsController.skippedIndex = null;
  }
}

class TestStatsController {
  static int currentIndex = 0;
  static int? skippedIndex;
}

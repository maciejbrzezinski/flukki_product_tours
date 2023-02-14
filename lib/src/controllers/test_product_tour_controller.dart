import '../models/product_tour_model.dart';

class TestProductTourController {
  int currentIndex = 0;
  ProductTour productTour;

  TestProductTourController(this.productTour) {
    productTour.currentIndex = 0;
    productTour.skippedIndex = null;
  }
}

import '../controllers/statistics_controller.dart';
import 'product_tour_step_model.dart';

class ProductTour {
  String? id;
  List<ProductTourStep> _steps = [];
  String? name;
  String? appName;
  String? minAppVersion;

  bool get isFinished =>
      StatisticsController.instance.isProductTourFinished(this);

  //int get stepsCount => _steps.length; TODO: WHY?
  int get stepsCount {
    final ids = <int>{};
    for (var element in _steps) {
      ids.add(element.index);
    }
    return ids.length;
  }

  int get currentIndex =>
      StatisticsController.instance.getCurrentStepIndex(this);

  int? get skippedIndex => StatisticsController.instance.getSkippedIndex(this);

 


  ProductTour();

  ProductTour.fromJson(
      Map<String, dynamic> json, Map<String, void Function()> callbacks,
      {this.appName})
      : _steps = ProductTourStep.fromJsonList(
            List<Map<String, dynamic>>.from(json['steps']),
            callbacks: callbacks),
        id = json['id'],
        minAppVersion = json['minAppVersion'],
        name = json['name'] ?? 'Random name';

  List<ProductTourStep> get steps => _steps;

  ProductTourStep? get currentStep {
    final currentIndex =
        StatisticsController.instance.getCurrentStepIndex(this);
    if (currentIndex > stepsCount - 1) {
      return null;
    }
    return _steps[currentIndex];
  }

  ProductTourStep addStep(ProductTourStep productTourStep) {
    _steps.add(productTourStep);
    return _steps.last;
  }

  ProductTour clone() {
    final newProductTour = ProductTour();
    newProductTour._steps = _steps.map((e) => e.clone()).toList();
    newProductTour.name = name;
    newProductTour.id = id;
    return newProductTour;
  }

  Map<String, dynamic> toJson({bool withCurrentIndex = true}) =>
      {'steps': _steps.map((e) => e.toJson()).toList(), 'id': id, 'name': name};

  static List<ProductTour>? fromJsonList(List<Map<String, dynamic>> jsons,
          Map<String, void Function()> callbacks) =>
      jsons.map((json) => ProductTour.fromJson(json, callbacks)).toList();
}

import 'package:flukki_product_tours/src/helpers/app_version_controller.dart';

import 'product_tour_step_model.dart';

class ProductTour {
  String? id;
  List<ProductTourStep> _steps = [];
  int currentIndex = 0;
  int? skippedIndex;
  String? name;
  String? appName;
  String? minAppVersion;

  bool get isFinished => currentIndex >= stepsCount || skippedIndex != null;

  //int get stepsCount => _steps.length;
  int get stepsCount {
    final ids = <int>{};
    for (var element in _steps) {
      ids.add(element.index);
    }
    return ids.length;
  }

  ProductTour();

  ProductTour.fromJson(
      Map<String, dynamic> json, Map<String, void Function()> callbacks,
      {this.appName})
      : currentIndex = json['currentIndex'] ?? 0,
        skippedIndex = json['skippedIndex'],
        _steps = ProductTourStep.fromJsonList(
            List<Map<String, dynamic>>.from(json['steps']),
            callbacks: callbacks),
        id = json['id'],
        minAppVersion = json['minAppVersion'],
        name = json['name'] ?? 'Random name';

  List<ProductTourStep> get steps => _steps;

  ProductTourStep? get currentStep {
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
    newProductTour.currentIndex = currentIndex;
    newProductTour._steps = _steps.map((e) => e.clone()).toList();
    newProductTour.name = name;
    newProductTour.id = id;
    newProductTour.skippedIndex = skippedIndex;
    newProductTour.minAppVersion = minAppVersion;
    return newProductTour;
  }

  Map<String, dynamic> toJson({bool withCurrentIndex = true}) => {
        if (withCurrentIndex) 'currentIndex': currentIndex,
        if (withCurrentIndex) 'skippedIndex': skippedIndex,
        'steps': _steps.map((e) => e.toJson()).toList(),
        'id': id,
        'name': name,
        'minAppVersion': minAppVersion
      };

  bool hasMatchingProductTourSteps(List<String> widgetTree) {
    return _steps
        .where((step) =>
            step.index == currentIndex &&
            (step is AnnouncementProductTourStep ||
                (step is PointerProductTourStep &&
                    step.widgetKey == widgetTree.toString())))
        .isNotEmpty;
  }

  bool hasStepForTheWidget(String widget) {
    return _steps
        .where((step) =>
            step.index == currentIndex &&
            (step is PointerProductTourStep &&
                step.widgetKey.startsWith('[$widget')))
        .isNotEmpty;
  }

  static List<ProductTour>? fromJsonList(List<Map<String, dynamic>> jsons,
          Map<String, void Function()> callbacks) =>
      jsons.map((json) => ProductTour.fromJson(json, callbacks)).toList();
}

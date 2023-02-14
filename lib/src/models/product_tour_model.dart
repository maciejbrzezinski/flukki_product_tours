import 'product_tour_step_model.dart';

class ProductTour {
  String? id;
  List<ProductTourStep> _steps = [];
  int currentIndex = 0;
  int? skippedIndex;
  String? name;
  String? appName;

  bool get isFinished => currentIndex >= stepsCount || skippedIndex != null;

  int get stepsCount => _steps.length;

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
    return newProductTour;
  }

  Map<String, dynamic> toJson({bool withCurrentIndex = true}) => {
        if (withCurrentIndex) 'currentIndex': currentIndex,
        if (withCurrentIndex) 'skippedIndex': skippedIndex,
        'steps': _steps.map((e) => e.toJson()).toList(),
        'id': id,
        'name': name
      };

  bool hasMatchingProductTourSteps(List<String> widgetTree, int widgetIndex) {
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

import 'dart:async';

import '../helpers/device_id_controller.dart';
import '../models/product_tour_model.dart';
import 'product_tours_controller.dart';
import 'statistics_controller.dart';
import 'test_product_tour_controller.dart';

class FlukkiController {
  static final FlukkiController instance = FlukkiController._();

  FlukkiController._();

  bool _wasWidgetInspectorInitiated = false;
  bool _isInBuilderMode = false;
  bool _isInBuilderTestMode = false;
  Map<String, void Function()> callbacks = {};
  String? apiKey;
  String? appId;

  final StreamController<bool> _onCreationModeChanged =
      StreamController.broadcast();

  Stream<bool> get onCreationModeChanged => _onCreationModeChanged.stream;

  bool get isInBuilderMode => _isInBuilderMode;

  bool get isInBuilderTestMode => _isInBuilderTestMode;

  bool get wasWidgetInspectorInitiated => _wasWidgetInspectorInitiated;

  Future<void> initialize(
      {required String key,
      required String appName,
      Map<String, void Function()>? callbacks}) async {
    apiKey = key;
    appId = appName;
    this.callbacks = callbacks ?? {};
    await DeviceIdController.instance.init(key);
    await ProductToursController.instance
        .initialize(this.callbacks, DeviceIdController.instance.deviceId);
    StatisticsController.instance.sendStatistics();
  }

  void widgetExplorerInitiated() {
    _wasWidgetInspectorInitiated = true;
  }

  TestProductTourController? testProductTourController;

  Future<void> turnOnTestMode(ProductTour productTour) async {
    testProductTourController = TestProductTourController(productTour);
    _isInBuilderTestMode = true;
  }

  Future<void> turnOffTestMode() async {
    testProductTourController = null;
    _isInBuilderTestMode = false;
  }

  void turnOffBuilder() {
    _isInBuilderMode = false;
    _onCreationModeChanged.add(_isInBuilderMode);
  }

  void turnOnBuilder() {
    _isInBuilderMode = true;
    _onCreationModeChanged.add(_isInBuilderMode);
  }
}

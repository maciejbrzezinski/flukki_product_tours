import 'dart:async';

import 'package:flukki_product_tours/src/helpers/app_version_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../helpers/user_controller.dart';
import '../models/product_tour_model.dart';
import 'context_controller.dart';
import 'product_tours_controller.dart';
import 'statistics_controller.dart';
import 'test_product_tour_controller.dart';

class FlukkiController {
  static final FlukkiController instance = FlukkiController._();

  FlukkiController._() {
    assert(const bool.fromEnvironment('flutter.memory_allocations') == true,
        'Environment variable not set. Add <flutter.memory_allocations=true> environment variable. Your run method should look like this "--dart-define=flutter.memory_allocations=true"');
    MemoryAllocations.instance.addListener((event) {
      if (event.object is Element) {
        if (event is ObjectCreated) {
          ContextController.instance.addElement(event.object as Element);
        } else if (event is ObjectDisposed) {
          ContextController.instance.removeElement(event.object as Element);
        }
      }
    });
    WidgetsBinding.instance.addPersistentFrameCallback(
        ContextController.instance.performCheckIfPossible);
  }

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

  Future<void> initialize(
      {required String key,
      required String appName,
      Map<String, void Function()>? callbacks}) async {
    apiKey = key;
    appId = appName;
    this.callbacks = callbacks ?? {};
    await UserController.instance.init(key);
  }

  TestProductTourController? testProductTourController;

  Future<void> turnOnTestMode(ProductTour productTour) async {
    testProductTourController = TestProductTourController(productTour);
    _isInBuilderTestMode = true;
    ContextController.instance.flushAwaiting();
    ContextController.instance.performCheck();
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

  Future<void> signIn({String? userID}) async {
    assert(apiKey != null,
        'Plugin not initialized. Initialize plugin first, and then sign in user');

    await UserController.instance.signIn(apiKey!, userId: userID);
    await ProductToursController.instance
        .initialize(callbacks, UserController.instance.userID);
    await StatisticsController.instance.fetchStatistics();
    ContextController.instance.flushAwaiting();
    ContextController.instance.performCheck();
  }

  Future<void> signOut() async {
    await UserController.instance.signOut();
    await StatisticsController.instance.clear();
  }
}

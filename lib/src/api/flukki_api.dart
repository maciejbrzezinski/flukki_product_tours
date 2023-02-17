import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:collection/collection.dart';

import '../controllers/flukki_controller.dart';
import '../controllers/statistics_controller.dart';
import '../models/product_tour_model.dart';
import '../widgets/page_widgets/image_widget.dart';

class FlukkiApi {
  static const apiAddressPrefix =
      'https://us-central1-flukki-web.cloudfunctions.net/';

  static Dio get dio =>
      Dio(BaseOptions(contentType: Headers.jsonContentType, headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': '',
        'Access-Control-Allow-Methods': '*',
        'Access-Control-Allow-Credentials': 'true',
      }));

  static Future<bool> uploadOverlayKeys(
      {required List<String> highlightKeys,
      required String appName,
      required String apiKey}) async {
    try {
      await dio.post('${apiAddressPrefix}uploadHighlights?key=$apiKey',
          data: {'appName': appName, 'keys': jsonEncode(highlightKeys)});
      return true;
    } catch (e) {
      return false;
    }
  }

  static uploadCallbacks(
      {required List<String> callbacks,
      required String appName,
      required String apiKey}) async {
    try {
      await dio.post('${apiAddressPrefix}uploadCallbacks?key=$apiKey',
          data: {'appName': appName, 'callbacks': jsonEncode(callbacks)});
      return true;
    } catch (e) {
      return false;
    }
  }

  static uploadPluginVersion(
      {required String appName,
      required String apiKey,
      required String version}) async {
    try {
      await dio.post('${apiAddressPrefix}uploadPluginVersion?key=$apiKey',
          data: {'appName': appName, 'version': version});
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> saveProductTour(
      {required String appName,
      required String apiKey,
      required ProductTour productTour}) async {
    try {
      final productTourAsString =
          jsonEncode(productTour.toJson(withCurrentIndex: false));
      final response = await dio.post(
          '${apiAddressPrefix}saveProductTour?key=$apiKey',
          data: {'appName': appName, 'productTour': productTourAsString});
      return response.data['id'];
    } catch (e) {
      return null;
    }
  }

  static Future<List<ProductTour>?> fetchProductTours(
      {required String? deviceId}) async {
    String apiKey = FlukkiController.instance.apiKey!;
    String appName = FlukkiController.instance.appId!;
    var callbacks = FlukkiController.instance.callbacks;

    try {
      if (deviceId == null) {
        return [];
      }
      final response = await dio.post(
          '${apiAddressPrefix}getProductTours?key=$apiKey&appName=$appName',
          data: {'deviceId': deviceId});
      return ProductTour.fromJsonList(
          List<Map<String, dynamic>>.from(response.data['result']
              .map((e) => jsonDecode(e['productTour']))
              .toList()),
          callbacks);
    } catch (e) {
      /// 402 error means that you've used your monthly active users limit
      return null;
    }
  }

  static removeProductTour(ProductTour productTour) async {
    String apiKey = FlukkiController.instance.apiKey!;
    String appName = FlukkiController.instance.appId!;
    try {
      final response = await dio.post(
          '${apiAddressPrefix}removeProductTour?key=$apiKey',
          data: {'appName': appName, 'productTourID': productTour.id});
      return response.data['id'];
    } catch (e) {
      return null;
    }
  }

  static Future<String?> uploadImage(ImageWidget imageWidget) async {
    String apiKey = FlukkiController.instance.apiKey!;
    String appName = FlukkiController.instance.appId!;

    try {
      final response =
          await dio.post('${apiAddressPrefix}uploadFile?key=$apiKey', data: {
        'fileToUpload': const Base64Encoder().convert(imageWidget.photoBytes!),
        'fileName': DateTime.now().toIso8601String() + imageWidget.fileName!,
        'appName': appName
      });
      return response.data['url'].first;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> createDeviceId({required String apiKey}) async {
    try {
      final response =
          await dio.post('${apiAddressPrefix}createDeviceId?key=$apiKey');
      final id = response.data['deviceId'];
      return id;
    } catch (e) {
      /// 402 error means that you've used your monthly active users limit
      return null;
    }
  }

  static updateDeviceId(
      {required String deviceId, required String apiKey}) async {
    try {
      await dio.post('${apiAddressPrefix}updateDeviceId?key=$apiKey',
          data: {'deviceId': deviceId});
    } catch (e) {
      /// 402 error means that you've used your monthly active users limit
      return null;
    }
  }

  static sendStatistics(
      {required String appName,
      required String deviceId,
      required String apiKey,
      required List<ProductTourProgress> statistics}) async {
    try {
      await dio.post('${apiAddressPrefix}sendStats?key=$apiKey', data: {
        'deviceId': deviceId,
        'appName': statistics.firstWhereOrNull((e) => true)?.appName ?? appName,
        'stats': statistics.map((stats) => stats.toJson()).toList()
      });
    } catch (_) {}
  }
}

import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:collection/collection.dart';
import 'package:flutter/rendering.dart';

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
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw FlukkiWrongKeyException('Provided api key ($apiKey) is wrong');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
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
          List<Map<String, dynamic>>.from(
              response.data['result'].where((e) => e != null).toList().map((e) {
            final decoded = jsonDecode(e['productTour']);
            decoded['id'] = e['id'];
            return decoded;
          }).toList()),
          callbacks);
    } on DioError catch (e) {
      if (e.response?.statusCode == 402) {
        throw FlukkiOutOfCreditsException(
            'You have exceeded your monthly active users limit');
      } else if (e.response?.statusCode == 401) {
        throw FlukkiWrongKeyException('Provided api key ($apiKey) is wrong');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static removeProductTour(ProductTour productTour) async {
    String apiKey = FlukkiController.instance.apiKey!;
    String appName = FlukkiController.instance.appId!;
    try {
      await dio.post('${apiAddressPrefix}removeProductTour?key=$apiKey',
          data: {'appName': appName, 'productTourID': productTour.id});
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw FlukkiWrongKeyException('Provided api key ($apiKey) is wrong');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
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
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw FlukkiWrongKeyException('Provided api key ($apiKey) is wrong');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static Future<String?> createDeviceId({required String apiKey}) async {
    try {
      final response =
          await dio.post('${apiAddressPrefix}createDeviceId?key=$apiKey');
      final id = response.data['deviceId'];
      return id;
    } on DioError catch (e) {
      if (e.response?.statusCode == 402) {
        throw FlukkiOutOfCreditsException(
            'You have exceeded your monthly active users limit');
      } else if (e.response?.statusCode == 401) {
        throw FlukkiWrongKeyException('Provided api key ($apiKey) is wrong');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }

  static updateDeviceId(
      {required String userID, required String apiKey}) async {
    try {
      await dio.post('${apiAddressPrefix}updateDeviceId?key=$apiKey',
          data: {'deviceId': userID});
    } on DioError catch (e) {
      if (e.response?.statusCode == 402) {
        throw FlukkiOutOfCreditsException(
            'You have exceeded your monthly active users limit');
      } else if (e.response?.statusCode == 401) {
        throw FlukkiWrongKeyException('Provided api key ($apiKey) is wrong');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static sendStatistics(
      {required String appName,
      required String userID,
      required String apiKey,
      required List<ProductTourProgress> statistics}) async {
    try {
      await dio.post('${apiAddressPrefix}sendStats?key=$apiKey', data: {
        'deviceId': userID,
        'appName': statistics.firstWhereOrNull((e) => true)?.appName ?? appName,
        'stats': statistics.map((stats) => stats.toJson()).toList()
      });
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw FlukkiOutOfCreditsException(
            'You have exceeded your monthly active users limit');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<List<ProductTourProgress>?> fetchStatistics(
      {required String apiKey,
      required String appName,
      required String userID,
      required List<String> productTourIDs}) async {
    try {
      final response = await dio
          .post('${apiAddressPrefix}fetchStats?key=$apiKey', data: {
        'deviceId': userID,
        'appName': appName,
        'productTourIDs': productTourIDs
      });
      final statsJson = response.data['stats'];
      if (statsJson[0] == null) {
        return null;
      }
      return List<ProductTourProgress>.from(
          statsJson.map((e) => ProductTourProgress.fromJson(e)));
    } on DioError catch (e) {
      if (e.response?.statusCode == 401) {
        throw FlukkiOutOfCreditsException(
            'You have exceeded your monthly active users limit');
      } else {
        debugPrint(e.toString());
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}

class FlukkiOutOfCreditsException implements Exception {
  String message;

  FlukkiOutOfCreditsException(this.message);
}

class FlukkiWrongKeyException implements Exception {
  String message;

  FlukkiWrongKeyException(this.message);
}

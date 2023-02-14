import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../constants.dart';
import '../models/product_tour_model.dart';

class LocalStorageController {
  static Future<void> saveProductTour(ProductTour productTour) async {
    final preferences = await SharedPreferences.getInstance();
    var savedProductTours =
        preferences.getStringList(FlukkiContants.productToursPreferencesKey) ??
            [];
    var productTourJson = productTour.toJson();
    var asString = jsonEncode(productTourJson);
    bool wasExisting = false;
    savedProductTours = savedProductTours.map((element) {
      if (jsonDecode(element)['id'] == productTour.id) {
        wasExisting = true;
        return asString;
      }
      return element;
    }).toList();
    if (!wasExisting) {
      savedProductTours.add(asString);
    }
    await preferences.setStringList(
        FlukkiContants.productToursPreferencesKey, savedProductTours);
  }
}

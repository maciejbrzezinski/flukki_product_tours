import 'package:flutter/material.dart';

import '../models/product_tour_model.dart';
import '../widgets/previews.dart';

class ProductTourHelperMethods {
  static Future<dynamic> runAsPage(
      BuildContext context, ProductTour productTour) async {
    return await Navigator.of(context).push(MaterialPageRoute(builder: (ctx) {
      return Scaffold(
        body: createProductTourWidget(productTour, context),
      );
    }));
  }

  static Future<dynamic> runAsBottomSheet(
      BuildContext context, ProductTour productTour) async {
    return await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (ctx) => Wrap(
              children: [
                createProductTourWidget(productTour, context),
              ],
            ));
  }

  static Future<dynamic> runAsPopup(
      BuildContext context, ProductTour productTour) async {
    return await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Container(
                constraints: const BoxConstraints(maxHeight: 500),
                child: createProductTourWidget(productTour, context),
              ),
            ));
  }

  static Widget createProductTourWidget(
      ProductTour productTour, BuildContext context) {
    return ProductTourPreview(
      productTour: productTour,
    );
  }
}

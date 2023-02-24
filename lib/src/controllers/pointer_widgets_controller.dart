import 'package:collection/collection.dart';
import 'package:flukki_product_tours/src/controllers/product_tours_controller.dart';
import 'package:flutter/material.dart';

import '../helpers/product_tour_helper_methods.dart';
import '../helpers/product_tour_matcher.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';
import '../widgets/overlay_with_caption.dart';
import 'flukki_controller.dart';
import 'widgets_on_screen_controller.dart';

class UserWidgetsController {
  static UserWidgetsController get instance => _instance;
  static final UserWidgetsController _instance = UserWidgetsController._();
  BuildContext? _context;

  set buildContext(BuildContext context) => _context = context;

  UserWidgetsController._();

  /// widgetName, widgetKey, list of elements
  final Map<String, Map<String, List<PointerElement>>>
      _pointerElementsPerWidget = {};

  void addElement(PointerElement pointerElement) {
    Element? element = pointerElement.element;
    if (!element.mounted) {
      return;
    }
    _pointerElementsPerWidget.putIfAbsent(pointerElement.widgetName, () => {});
    _pointerElementsPerWidget[pointerElement.widgetName]!
        .putIfAbsent(pointerElement.widgetTree, () => []);
    _pointerElementsPerWidget[pointerElement.widgetName]![
            pointerElement.widgetTree]!
        .add(pointerElement);
  }

  void performCheck() {
    if (ProductToursController.instance.isStepDisplayed) return;
    if (!FlukkiController.instance.isInBuilderTestMode &&
        ProductToursController.instance.productTours.isEmpty) return;

    clearNotMountedElements();

    final announcementProductTour =
        ProductTourMatcher.getAnnouncementProductTour();
    if (announcementProductTour != null) {
      _showAnnouncementToUser(announcementProductTour, _context!);
      return;
    }

    List<ProductTour> currentProductTours =
        ProductTourMatcher.getProductToursWithCurrentPointer();

    PointerElement? matchingElement;
    final productTour = currentProductTours.firstWhereOrNull((productTour) {
      final currentStep = productTour.currentStep as PointerProductTourStep;
      final elements = _pointerElementsPerWidget[currentStep.widgetName]
              ?[currentStep.widgetKey] ??
          [];
      if (elements.length - 1 >= currentStep.widgetIndex) {
        matchingElement = elements[currentStep.widgetIndex];
        return true;
      }
      return false;
    });

    if (productTour != null && matchingElement != null) {
      final box = matchingElement!.element.renderObject as RenderBox;
      if (_context != null) {
        _pointWidgetUser(_context!, box, productTour);
      }
    }
  }

  static OverlayEntry? lastEntry;

  static void _pointWidgetUser(BuildContext contextToExplore, RenderBox box,
      ProductTour productTour) async {
    if (lastEntry == null) {
      final position = box.localToGlobal(Offset.zero);
      lastEntry = _createOverlay(box, position,
          productTour.currentStep as PointerProductTourStep, productTour);
      Overlay.of(contextToExplore).insert(lastEntry!);
      ProductToursController.instance.isStepDisplayed = true;
    }
  }

  static Future<void> _showAnnouncementToUser(
      ProductTour productTour, BuildContext context) async {
    ProductToursController.instance.isStepDisplayed = true;
    final currentStep = productTour.steps[productTour.currentIndex]
        as AnnouncementProductTourStep;
    switch (currentStep.displayStyle) {
      case DisplayStyle.bottomSheet:
        await ProductTourHelperMethods.runAsBottomSheet(context, productTour);
        break;
      case DisplayStyle.page:
        await ProductTourHelperMethods.runAsPage(context, productTour);
        break;
      case DisplayStyle.popup:
        await ProductTourHelperMethods.runAsPopup(context, productTour);
        break;
    }
    await ProductToursController.instance.madeProgress(productTour,
        isAnnouncement: true,
        isTestMode: FlukkiController.instance.isInBuilderTestMode);
    if (productTour.isFinished) {
      ProductToursController.instance.isStepDisplayed = false;
      if (FlukkiController.instance.isInBuilderTestMode) {
        FlukkiController.instance.turnOffTestMode();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        ProductToursController.instance.isStepDisplayed = false;
        instance.performCheck();
      });
    }
  }

  static OverlayEntry _createOverlay(RenderBox box, Offset position,
      PointerProductTourStep productTourStep, ProductTour productTour) {
    return OverlayEntry(
        builder: (ctx) => OverlayWithCaption(() {
              lastEntry?.remove();
              lastEntry = null;
            }, box, position, productTourStep, productTour, () {}));
  }

  void clearNotMountedElements() {
    for (var element in _pointerElementsPerWidget.values) {
      element.forEach((key, value) {
        value.removeWhere((pointerElement) {
          final isMounted = pointerElement.element.mounted;

          if (!isMounted) {
            final widgetName = pointerElement.widgetName;
            _pointerElementsPerWidget[widgetName]?.remove(pointerElement);
          }
          return !isMounted;
        });
      });
    }
  }
}

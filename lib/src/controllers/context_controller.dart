import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flukki_product_tours/src/controllers/statistics_controller.dart';
import 'package:flukki_product_tours/src/helpers/product_tour_matcher.dart';
import 'package:flutter/material.dart';

import '../helpers/product_tour_helper_methods.dart';
import '../helpers/user_controller.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';
import '../widgets/element_with_widget_tree.dart';
import '../widgets/overlay_with_caption.dart';
import 'flukki_controller.dart';
import 'product_tours_controller.dart';

class ContextController {
  static ContextController get instance => _instance;
  static final ContextController _instance = ContextController._();

  List<FatElement> elements = [];
  final Map<String, LinkedHashSet<FatElement>> _elementsPerWidgetType = {};
  BuildContext? _context;

  set buildContext(BuildContext context) => _context = context;
  List<Element> awaiting = [];

  ContextController._();

  void addElement(Element e) {
    if (!e.mounted) return;
    awaiting.add(e);
  }

  bool flushAwaiting() {
    final result = awaiting.isNotEmpty;
    for (Element element in awaiting) {
      try {
        if (!element.mounted) continue;
        final fatElement = FatElement.fromElement(element);
        _elementsPerWidgetType.putIfAbsent(
            fatElement.croppedWidgetName, () => LinkedHashSet());
        _elementsPerWidgetType[fatElement.croppedWidgetName]!.add(fatElement);

        elements.add(fatElement);
      } catch (_) {}
    }
    awaiting.clear();
    return result;
  }

  void removeElement(Element element) {
    elements.removeWhere((e) => e.element == element);
    final widgetName = ProductTourMatcher.cropWidgetName(element);
    _elementsPerWidgetType[widgetName]
        ?.removeWhere((fatElement) => fatElement.element == element);
  }

  ElementWithWidgetTree? getMatchingElement(Offset mousePosition) {
    Size? previousSize;
    FatElement? bestMatch;
    try {
      for (FatElement fatElement in elements) {
        final isInside = fatElement.isMouseInsideElementArea(mousePosition);
        if (isInside) {
          final size = fatElement.size!;
          if (previousSize == null) {
            previousSize = size;
            bestMatch = fatElement;
          } else if (previousSize > size) {
            previousSize = size;
            bestMatch = fatElement;
          }
        }
      }
      if (bestMatch == null) return null;

      List<Element> toDelete = [];
      List<FatElement> elementsWithTheSameWidgetTree = [];
      try {
        elementsWithTheSameWidgetTree =
            _elementsPerWidgetType[bestMatch.croppedWidgetName]!
                .where((fatElement) {
          if (!fatElement.element.mounted) {
            toDelete.add(fatElement.element);
            return false;
          }
          if (fatElement.element == bestMatch!.element) return true;

          if (fatElement.widgetTreeList.toString() ==
              bestMatch.widgetTreeList.toString()) return true;
          return false;
        }).toList();
        _elementsPerWidgetType[bestMatch.croppedWidgetName]!
            .removeAll(toDelete);
      } catch (_) {}

      return ElementWithWidgetTree(
          widgetName: ProductTourMatcher.cropWidgetName(bestMatch.element),
          element: bestMatch.element,
          widgetTree: bestMatch.widgetTreeList,
          index: elementsWithTheSameWidgetTree.indexOf(bestMatch));
    } catch (_) {
      return null;
    }
  }

  void performCheckIfPossible(timeStamp) {
    if (UserController.instance.isSignedIn &&
        ContextController.instance.flushAwaiting()) {
      ContextController.instance.performCheck();
    }
  }

  void performCheck() {
    if(_context == null) return;
    if (ProductToursController.instance.isStepDisplayed) return;
    if (!FlukkiController.instance.isInBuilderTestMode &&
        ProductToursController.instance.productTours.isEmpty) return;

    final announcementProductTour =
        ProductTourMatcher.getAnnouncementProductTour();
    if (announcementProductTour != null) {
      _showAnnouncementToUser(announcementProductTour, _context!);
      return;
    }

    List<ProductTour> currentProductTours =
        ProductTourMatcher.getProductToursWithCurrentPointer();

    FatElement? matchingElement;
    final productTour = currentProductTours.firstWhereOrNull((productTour) {
      final currentStep = productTour.currentStep as PointerProductTourStep;
      final elements = _elementsPerWidgetType[currentStep.widgetName]
          ?.where((element) => element.widgetTree == currentStep.widgetKey);

      if (elements != null &&
          currentStep.widgetIndex >= 0 &&
          elements.length - 1 >= currentStep.widgetIndex) {
        matchingElement = elements.elementAt(currentStep.widgetIndex);
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
    final currentStep = productTour.steps[StatisticsController.instance
        .getCurrentStepIndex(productTour)] as AnnouncementProductTourStep;
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
}

class FatElement {
  List<String>? _widgetTreeList;
  final Element element;
  final Widget widget;
  Size? _size;
  Offset? _position;

  FatElement({required this.element, required this.widget});

  factory FatElement.fromElement(Element element) {
    return FatElement(widget: element.widget, element: element);
  }

  String get widgetTree => widgetTreeList.toString();

  String get croppedWidgetName => ProductTourMatcher.cropWidgetName(element);

  Size? get size {
    if (_size == null) {
      final box = element.renderObject;
      if (box is RenderBox) {
        _size = box.size;
        _position = box.localToGlobal(Offset.zero);
      }
    }
    return _size;
  }

  Offset? get position {
    if (_position == null) {
      final box = element.renderObject;
      if (box is RenderBox) {
        _size = box.size;
        _position = box.localToGlobal(Offset.zero);
      }
    }
    return _position;
  }

  List<String> get widgetTreeList {
    if (_widgetTreeList == null) {
      _widgetTreeList = <String>[];
      element.visitAncestorElements(
          (e) => ProductTourMatcher.ancestorVisitor(e, _widgetTreeList!));
      _widgetTreeList!.insert(0, croppedWidgetName);
    }
    return _widgetTreeList!;
  }

  bool isMouseInsideElementArea(Offset mousePosition) {
    if (position == null || size == null) return false;
    return mousePosition.dx > position!.dx &&
        mousePosition.dx < position!.dx + size!.width &&
        mousePosition.dy > position!.dy &&
        mousePosition.dy < position!.dy + size!.height;
  }
}

import 'dart:collection';

import 'package:flukki_product_tours/src/helpers/product_tour_matcher.dart';
import 'package:flukki_product_tours/src/widgets/element_with_widget_tree.dart';
import 'package:flutter/material.dart';

class BuilderWidgetsController {
  final Map<EnhancedElement, ElementDetails?> _elementsWithDetails = {};
  final Map<String, LinkedHashSet<Element>> _elementsPerWidgetType = {};

  static BuilderWidgetsController get instance => _instance;
  static final BuilderWidgetsController _instance =
      BuilderWidgetsController._();

  BuilderWidgetsController._();

  void addElement(EnhancedElement enhancedElement) {
    Element? element = enhancedElement.element;
    if (!element.mounted) {
      return;
    }
    try {
      final box = element.renderObject;
      if (box is RenderBox) {
        final size = box.size;
        final position = box.localToGlobal(Offset.zero);
        final details = _elementsWithDetails.putIfAbsent(
            enhancedElement, () => ElementDetails(size, position));
        details!.size = size;
        details.position = position;

        final widgetName =
            ProductTourMatcher.cropWidgetName(element.widget.toString());
        _elementsPerWidgetType.putIfAbsent(widgetName, () => LinkedHashSet());
        _elementsPerWidgetType[widgetName]!
            .removeWhere((element) => !element.mounted);
        _elementsPerWidgetType[widgetName]!.add(element);
      }
    } catch (e, stack) {
      debugPrint('$e\n$stack');
    }
  }

  ElementWithWidgetTree? getMatchingElement(Offset mousePosition) {
    Size? previousSize;
    Element? bestMatch;
    try {
      for (MapEntry<EnhancedElement, ElementDetails?> mapEntry
          in _elementsWithDetails.entries) {
        final isInside =
            mapEntry.value?.isMouseInsideElementArea(mousePosition) == true;
        if (isInside) {
          final size = mapEntry.value!.size;
          if (previousSize == null) {
            previousSize = size;
            bestMatch = mapEntry.key.element;
          } else if (previousSize > size) {
            previousSize = size;
            bestMatch = mapEntry.key.element;
          }
        }
      }
      if (bestMatch == null) return null;

      final widgetName =
          ProductTourMatcher.cropWidgetName(bestMatch.widget.toString());
      List<String> ancestorsList = [];
      bestMatch.visitAncestorElements(
          (e) => ProductTourMatcher.ancestorVisitor(e, ancestorsList));
      ancestorsList.insert(0, widgetName);

      return ElementWithWidgetTree(
          widgetName:
              ProductTourMatcher.cropWidgetName(bestMatch.widget.toString()),
          element: bestMatch,
          widgetTree: ancestorsList,
          index:
              _elementsPerWidgetType[widgetName]!.toList().indexOf(bestMatch));
    } catch (_) {
      return null;
    }
  }

  void clearNotMountedElements() {
    _elementsWithDetails.removeWhere((key, value) {
      final isMounted = key.element.mounted;

      if (!isMounted) {
        final widgetName =
            ProductTourMatcher.cropWidgetName(key.widget.toString());
        _elementsPerWidgetType[widgetName]?.remove(key);
      }

      return !isMounted;
    });
  }
}

class ElementDetails {
  Size size;
  Offset position;

  ElementDetails(this.size, this.position);

  bool isMouseInsideElementArea(Offset mousePosition) =>
      mousePosition.dx > position.dx &&
      mousePosition.dx < position.dx + size.width &&
      mousePosition.dy > position.dy &&
      mousePosition.dy < position.dy + size.height;
}

class EnhancedElement {
  Element element;
  Widget widget;

  EnhancedElement({required this.element, required this.widget});
}

class PointerElement {
  List<String> widgetTreeList;
  String widgetName;
  Element element;

  String get widgetTree => widgetTreeList.toString();

  PointerElement(
      {required this.element,
      required this.widgetTreeList,
      required this.widgetName});
}

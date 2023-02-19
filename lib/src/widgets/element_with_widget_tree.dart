import 'package:flutter/material.dart';

class ElementWithWidgetTree {
  Element element;
  List<String> widgetTree;
  int index;
  String widgetName;

  ElementWithWidgetTree(
      {required this.widgetName,
      required this.element,
      required this.widgetTree,
      required this.index});
}

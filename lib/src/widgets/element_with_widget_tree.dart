import 'package:flutter/material.dart';

class ElementWithWidgetTree {
  Element element;
  List<String> widgetTree;
  int index;

  ElementWithWidgetTree(
      {required this.element, required this.widgetTree, required this.index});
}

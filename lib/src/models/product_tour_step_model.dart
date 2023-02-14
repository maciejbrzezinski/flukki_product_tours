import 'package:flutter/material.dart';

import '../widgets/page_widgets/abstract_page_widget.dart';
import '../widgets/page_widgets/image_widget.dart';

abstract class ProductTourStep {
  int index;

  ProductTourStep(this.index);

  ProductTourStep.fromJson(Map<String, dynamic> json) : index = json['index'];

  static List<ProductTourStep> fromJsonList(List<Map<String, dynamic>> jsons,
      {required Map<String, void Function()> callbacks}) {
    final List<ProductTourStep> steps = [];
    for (Map<String, dynamic> json in jsons) {
      if (json['type'] == 'pointer') {
        steps.add(PointerProductTourStep.fromJson(json));
      } else {
        steps.add(
            AnnouncementProductTourStep.fromJson(json, callbacks: callbacks));
      }
    }
    return steps;
  }

  Map<String, dynamic> toJson();

  ProductTourStep clone();
}

class PointerProductTourStep extends ProductTourStep {
  static const String type = 'pointer';
  String caption;
  String widgetKey;
  late String? _action;
  int widgetIndex;

  PointerAction get pointerAction =>
      PointerAction.values.firstWhere((element) => element.name == _action);

  PointerProductTourStep(int index, this.caption, this.widgetKey,
      PointerAction action, this.widgetIndex)
      : super(index) {
    _action = action.name;
  }

  PointerProductTourStep.fromJson(Map<String, dynamic> json)
      : caption = json['caption'],
        widgetKey = json['widgetKey'],
        _action = json['action'],
        widgetIndex = json['widgetIndex'] ?? 0,
        super.fromJson(json);

  @override
  ProductTourStep clone() => PointerProductTourStep(
      index,
      caption,
      widgetKey,
      PointerAction.values.firstWhere((element) => element.name == _action),
      widgetIndex);

  @override
  Map<String, dynamic> toJson() => {
        'index': index,
        'caption': caption,
        'widgetKey': widgetKey,
        'action': _action,
        'type': type,
        'widgetIndex': widgetIndex,
      };
}

class AnnouncementProductTourStep extends ProductTourStep {
  static const String type = 'announcement';
  DisplayStyle displayStyle;
  List<AnnouncementWidget> widgets;
  Color? backgroundColor;
  bool isNew = true;

  AnnouncementProductTourStep(
    int index, {
    this.displayStyle = DisplayStyle.popup,
    List<AnnouncementWidget>? widgetsList,
    this.backgroundColor = Colors.white,
    this.isNew = true,
  })  : widgets = widgetsList ?? [],
        super(index);

  AnnouncementProductTourStep.fromJson(Map<String, dynamic> json,
      {required Map<String, void Function()> callbacks})
      : widgets = json['widgets'] == null
            ? []
            : AnnouncementWidget.fromList(json['widgets'],
                callbacks: callbacks),
        displayStyle = DisplayStyle.values.firstWhere((element) =>
            element.name == (json['displayStyle'] ?? 'bottomSheet')),
        backgroundColor = Color(json['backgroundColor'] ?? 0xFFffffff),
        super.fromJson(json) {
    isNew = false;
  }

  @override
  ProductTourStep clone() => AnnouncementProductTourStep(index,
      displayStyle: displayStyle,
      widgetsList: List.from(widgets),
      isNew: false);

  @override
  Map<String, dynamic> toJson() => {
        'index': index,
        'displayStyle': displayStyle.name,
        'widgets': widgets.map((e) => e.toJson()).toList(),
        'backgroundColor': backgroundColor?.value,
        'type': type
      };

  void replaceWidget(ImageWidget newWidget) {
    final index =
        widgets.indexWhere((element) => element.index == newWidget.index);
    if (index == -1) {
      widgets.add(newWidget);
    } else {
      widgets.removeAt(index);
      widgets.insert(index, newWidget);
    }
  }
}

enum DisplayStyle {
  bottomSheet('Bottom sheet'),
  page('Page'),
  popup('Popup');

  const DisplayStyle(this.name);
  final String name;
}

enum PointerAction { next, click }

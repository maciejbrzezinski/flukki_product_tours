import 'package:flutter/material.dart';

import 'button_widget.dart';
import 'image_widget.dart';
import 'text_widget.dart';

abstract class AnnouncementWidget extends StatelessWidget {
  final int index;

  static List<AnnouncementWidget> fromList(List<dynamic> widgets,
      {required Map<String, void Function()> callbacks}) {
    widgets.sort((a, b) => (a['index'] as int).compareTo(b['index'] as int));
    final result = <AnnouncementWidget>[];

    for (var widgetMap in widgets) {
      final type = widgetMap['type'];
      if (type == 'text') {
        result.add(TextWidget.fromJson(widgetMap));
      } else if (type == 'button') {
        final callback = callbacks[widgetMap['callback']];
        result.add(ButtonWidget.fromJson(widgetMap, callback));
      } else if (type == 'image') {
        result.add(ImageWidget.fromJson(widgetMap));
      }
    }

    return result;
  }

  const AnnouncementWidget({super.key, required this.index});

  Map<String, dynamic> toJson();
}

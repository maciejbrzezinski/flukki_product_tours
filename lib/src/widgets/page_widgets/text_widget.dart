import 'package:flutter/material.dart';
import 'abstract_page_widget.dart';

class TextWidget extends AnnouncementWidget {
  final TextStyling? textStyling;
  final String? value;

  const TextWidget(
      {super.key,
      this.textStyling = TextStyling.body,
      required this.value,
      required int index})
      : super(index: index);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    TextStyle? style = textTheme.bodyLarge;

    switch (textStyling) {
      case TextStyling.h1:
        style = textTheme.displayLarge;
        break;
      case TextStyling.h2:
        style = textTheme.displayMedium;
        break;
      case TextStyling.h3:
        style = textTheme.displaySmall;
        break;
      case TextStyling.body:
        style = textTheme.bodyLarge;
        break;
      case TextStyling.h4:
        style = textTheme.headlineMedium;
        break;
      case TextStyling.h5:
        style = textTheme.headlineSmall;
        break;
      case TextStyling.h6:
        style = textTheme.titleLarge;
        break;
      case TextStyling.caption:
        style = textTheme.bodySmall;
        break;
      default:
        style = textTheme.bodyLarge;
        break;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        value ?? '',
        style: style,
        textAlign: TextAlign.center,
      ),
    );
  }

  TextWidget.fromJson(Map<String, dynamic> widgetMap, {super.key})
      : textStyling = TextStylingValue.fromString(widgetMap['style']),
        value = widgetMap['value'],
        super(index: widgetMap['index']);

  TextWidget copyWith(
          {String? Function()? value,
          TextStyling? Function()? textStyling,
          int? index}) =>
      TextWidget(
        value: value == null ? this.value : value(),
        textStyling: textStyling == null ? this.textStyling : textStyling(),
        index: index ?? this.index,
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'text',
        'index': index,
        'style': textStyling.toString(),
        'value': value
      };
}

enum TextStyling { h1, h2, h3, h4, h5, h6, body, caption }

extension TextStylingValue on TextStyling {
  static TextStyling fromString(String? raw) {
    if (raw == null) {
      return TextStyling.body;
    }
    try {
      return TextStyling.values
          .firstWhere((element) => element.toString() == raw);
    } catch (_) {
      return TextStyling.body;
    }
  }
}

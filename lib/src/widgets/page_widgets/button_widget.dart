import 'package:flutter/material.dart';

import 'abstract_page_widget.dart';

class ButtonWidget extends AnnouncementWidget {
  final Function()? callback;
  final String? callbackKey;
  final String? title;
  final Color? backgroundColor;

  const ButtonWidget(
      {super.key,
      this.callback,
      this.title,
      this.backgroundColor,
      this.callbackKey,
      required int index})
      : super(index: index);

  ButtonWidget.fromJson(Map<String, dynamic> json, this.callback, {super.key})
      : title = json['title'],
        backgroundColor = json['backgroundColor'] == null
            ? null
            : Color(int.parse(json['backgroundColor'])),
        callbackKey = json['callback'],
        super(index: json['index']);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ElevatedButton(
        onPressed: callback,
        style: ButtonStyle(
          backgroundColor: backgroundColor == null
              ? null
              : MaterialStatePropertyAll(backgroundColor),
        ),
        child: Text(title ?? ''),
      ),
    );
  }

  ButtonWidget copyWith(
          {String? Function()? title,
          Color? Function()? backgroundColor,
          String? Function()? callbackKey,
          int? index}) =>
      ButtonWidget(
        callback: callback,
        title: title == null ? this.title : title(),
        index: index ?? this.index,
        backgroundColor:
            backgroundColor == null ? this.backgroundColor : backgroundColor(),
        callbackKey: callbackKey == null ? this.callbackKey : callbackKey(),
      );

  @override
  Map<String, dynamic> toJson() => {
        'type': 'button',
        'index': index,
        'title': title,
        'backgroundColor': backgroundColor?.value,
        'callback': callbackKey,
      };
}

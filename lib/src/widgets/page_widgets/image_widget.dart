import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'abstract_page_widget.dart';

class ImageWidget extends AnnouncementWidget {
  final String? address;
  final Uint8List? photoBytes;
  final String? fileName;

  const ImageWidget({
    super.key,
    this.address,
    this.photoBytes,
    this.fileName,
    required int index,
  }) : super(index: index);

  @override
  Widget build(BuildContext context) {
    Widget? image;
    if (address != null) {
      image = Image.network(address!);
    } else if (photoBytes != null) {
      image = Image.memory(photoBytes!);
    } else {
      image = const Text('Something went wrong');
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: image,
    );
  }

  ImageWidget.fromJson(Map<String, dynamic> widgetMap, {super.key})
      : address = widgetMap['address'],
        fileName = null,
        photoBytes = null,
        super(index: widgetMap['index']);

  ImageWidget copyWith(
          {String? Function()? address,
          int? index,
          Uint8List? photoBytes,
          String? fileName}) =>
      ImageWidget(
        address: address == null ? this.address : address(),
        index: index ?? this.index,
        photoBytes: photoBytes,
        fileName: fileName,
      );

  @override
  Map<String, dynamic> toJson() =>
      {'type': 'image', 'index': index, 'address': address};
}

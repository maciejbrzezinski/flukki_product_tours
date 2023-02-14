import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

class DragDropImageController {
  var isLoading = false;
  var imagesListLoaded = false;
  List imagesList = [];

  Future<void> pickImageLocal(BuildContext context) async {
    if (isLoading) return;

    final FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, allowMultiple: false);

    if (result == null) return;

    isLoading = true;

    Uint8List fileBytes = result.files.first.bytes!;
    isLoading = false;

    if (context.mounted) {
      getBack(context, fileBytes);
    }
  }

  Future<void> handleDropFiles(
      {required List? drop,
      required DropzoneViewController ctrl,
      required BuildContext context}) async {
    if (drop is! List) {
      isLoading = false;
      Navigator.of(context).pop();
      return;
    }
    if (drop.isNotEmpty && drop.length == 1) {
      if (drop.first.type.startsWith('image')) {
        isLoading = true;
        final bytes = await ctrl.getFileData(drop.single);
        final name = await ctrl.getFilename(drop.single);
        isLoading = false;
        if (context.mounted) {
          getBack(context, bytes, name);
        }
      } else {}
    } else if (drop.isNotEmpty && drop.length != 1) {
      // You can upload only one file
    } else {
      // No files selected
    }
  }

  bool getBack(BuildContext context, [Uint8List? bytes, String? fileName]) {
    if (bytes != null && fileName != null) {
      Navigator.of(context).pop(SelectedFile(bytes, fileName));
    } else {
      Navigator.of(context).pop();
    }
    return false;
  }
}

class SelectedFile {
  Uint8List bytes;
  String fileName;

  SelectedFile(this.bytes, this.fileName);
}

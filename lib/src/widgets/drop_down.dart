import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dropzone/flutter_dropzone.dart';

import '../controllers/drop_down_controller.dart';

class DragDropImage extends StatelessWidget {
  DragDropImage({Key? key}) : super(key: key);
  late final DropzoneViewController dropzoneController;
  final DragDropImageController dragDropImageController =
      DragDropImageController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => dragDropImageController.getBack(context),
      child: SizedBox(
        width: 1000,
        height: 570,
        child: Stack(
          children: [
            DropzoneView(
              onCreated: (DropzoneViewController ctrl) =>
                  dropzoneController = ctrl,
              onDropMultiple: (value) =>
                  dragDropImageController.handleDropFiles(
                      drop: value, ctrl: dropzoneController, context: context),
              operation: DragOperation.copy,
            ),
            Column(
              children: [
                const SizedBox(height: 20),
                DragDropWidget(
                  controller: dragDropImageController,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DragDropWidget extends StatelessWidget {
  final DragDropImageController controller;

  const DragDropWidget({required this.controller, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: (() => controller.pickImageLocal(context)),
        child: Container(
          height: 200,
          width: 600,
          color: Colors.blue,
          padding: const EdgeInsets.all(10),
          child: controller.isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.background,
                  ),
                )
              : MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: DottedBorder(
                      borderType: BorderType.RRect,
                      color: Theme.of(context).colorScheme.background,
                      strokeWidth: 3,
                      dashPattern: const [8, 4],
                      radius: const Radius.circular(10),
                      padding: EdgeInsets.zero,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.cloud_upload_outlined,
                              size: 80,
                              color: Theme.of(context).colorScheme.background,
                            ),
                            Text(
                              'Drop Files Here',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(color: Colors.white),
                            ),
                            Text(
                              'You can also tap to upload images from your local storage',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                          ],
                        ),
                      )),
                ),
        ),
      ),
    );
  }
}

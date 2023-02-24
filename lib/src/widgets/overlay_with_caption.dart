import 'package:flukki_product_tours/src/controllers/pointer_widgets_controller.dart';
import 'package:flutter/material.dart';

import '../controllers/flukki_controller.dart';
import '../controllers/product_tours_controller.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';

class OverlayWithCaption extends StatelessWidget {
  final VoidCallback closeOverlay;
  final RenderBox box;
  final Offset position;
  final PointerProductTourStep productTourStep;
  final ProductTour productTour;
  final VoidCallback continueProductTour;

  const OverlayWithCaption(this.closeOverlay, this.box, this.position,
      this.productTourStep, this.productTour, this.continueProductTour,
      {super.key});

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    var leftPadding = position.dx + box.size.width + 16;
    if (leftPadding > screenSize.width) {
      leftPadding = position.dx - 300;
    }
    if (leftPadding < 0) {
      leftPadding = position.dx + (box.size.width / 2) - 150;
    }
    if (leftPadding + 300 > screenSize.width) {
      leftPadding = screenSize.width - 300;
    }
    var topPadding = position.dy + box.size.height + 16;
    if (topPadding + 250 > screenSize.height) {
      topPadding -= 250;
    }
    return Listener(
      onPointerDown: (event) {
        if (productTourStep.pointerAction == PointerAction.click &&
            _clickedPointedWidget(event)) {
          _nextStep();
        }
      },
      behavior: HitTestBehavior.translucent,
      child: ClipPath(
        clipper: InvertedClipper(box, position, leftPadding, topPadding),
        child: Container(
          color: Colors.black.withOpacity(.7),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                  left: position.dx,
                  top: position.dy,
                  child: Container(
                    color: Colors.transparent,
                    width: box.size.width,
                    height: box.size.height,
                  )),
              Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: EdgeInsets.only(top: topPadding, left: leftPadding),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(
                          Radius.circular(4),
                        )),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 16.0, right: 16, top: 8, bottom: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    productTourStep.caption,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _pointerActionToWidget(
                              productTourStep.pointerAction, context)
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _nextStep() async {
    await ProductToursController.instance.madeProgress(productTour,
        isTestMode: FlukkiController.instance.isInBuilderTestMode);
    closeOverlay();
    if (productTour.isFinished) {
      ProductToursController.instance.isStepDisplayed = false;
      if (FlukkiController.instance.isInBuilderTestMode) {
        FlukkiController.instance.turnOffTestMode();
      }
    } else {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        ProductToursController.instance.isStepDisplayed = false;
        UserWidgetsController.instance.performCheck();
      });
    }
  }

  Widget _pointerActionToWidget(
      PointerAction pointerAction, BuildContext context) {
    Widget progressWidget;
    switch (pointerAction) {
      case PointerAction.next:
        progressWidget = TextButton(
            onPressed: () {
              _nextStep();
            },
            child: Text(productTour.currentIndex == productTour.stepsCount - 1
                ? 'Finish'
                : 'Next'));
        break;
      case PointerAction.click:
        progressWidget = Text('Click on the element',
            style: Theme.of(context).textTheme.bodySmall);
        break;
    }
    return Row(
      mainAxisAlignment: productTour.currentIndex == productTour.stepsCount - 1
          ? MainAxisAlignment.end
          : MainAxisAlignment.spaceBetween,
      children: [
        if (productTour.currentIndex != productTour.stepsCount - 1)
          TextButton(
              onPressed: () => _skipAll(),
              child: Text(
                'Skip all',
                style: Theme.of(context).textTheme.bodySmall,
              )),
        progressWidget
      ],
    );
  }

  _skipAll() async {
    closeOverlay();
    await ProductToursController.instance.skipAll(productTour);
    ProductToursController.instance.isStepDisplayed = false;
    if (FlukkiController.instance.isInBuilderTestMode) {
      FlukkiController.instance.turnOffTestMode();
    }
  }

  bool _clickedPointedWidget(PointerDownEvent event) {
    final clickPosition = event.position;
    final widgetSize = box.size;
    return clickPosition.dy > position.dy &&
        clickPosition.dy < (position.dy + widgetSize.height) &&
        clickPosition.dx > position.dx &&
        clickPosition.dx < (position.dx + widgetSize.width);
  }
}

class InvertedClipper extends CustomClipper<Path> {
  RenderBox box;
  Offset position;
  double leftPadding;
  double topPadding;

  InvertedClipper(this.box, this.position, this.leftPadding, this.topPadding);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromLTRBAndCorners(
        position.dx - 4,
        position.dy - 4,
        position.dx + box.size.width + 4,
        position.dy + box.size.height + 4,
        topLeft: const Radius.circular(1),
        bottomLeft: const Radius.circular(1),
        bottomRight: const Radius.circular(1),
        topRight: const Radius.circular(1),
      ))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class CustomCircular extends CustomClipper<Path> {
  double percentage;

  CustomCircular(this.percentage);

  @override
  Path getClip(Size size) {
    final path = Path();
    path.fillType = (PathFillType.evenOdd);
    var radius = size.width / 2;
    var internalRadius = radius * percentage;
    path.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: internalRadius));
    path.addOval(Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2), radius: radius));
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomCircular oldClipper) => false;
}

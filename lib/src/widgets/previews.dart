import 'package:flukki_product_tours/src/controllers/statistics_controller.dart';
import 'package:flutter/material.dart';

import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';

class AnnouncementStepPreview extends StatelessWidget {
  final AnnouncementProductTourStep step;

  const AnnouncementStepPreview({required this.step, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        children: step.widgets.map((child) => Flexible(child: child)).toList());
  }
}

class ProductTourPreview extends StatefulWidget {
  final ProductTour productTour;

  const ProductTourPreview({
    super.key,
    required this.productTour,
  });

  @override
  State<ProductTourPreview> createState() => _ProductTourPreviewState();
}

class _ProductTourPreviewState extends State<ProductTourPreview> {
  late int index;
  late int initialIndex;
  late ProductTourProgress progress;
  int stepsToShow = 1;

  @override
  void initState() {
    super.initState();
    progress = StatisticsController.instance.getProgress(widget.productTour);
    index = progress.currentStep;
    initialIndex = progress.currentStep;
    final currentStep =
        widget.productTour.steps[index] as AnnouncementProductTourStep;
    for (int i = index + 1; i < widget.productTour.stepsCount; i++) {
      final compareStep = widget.productTour.steps[i];
      if (compareStep is AnnouncementProductTourStep &&
          compareStep.displayStyle == currentStep.displayStyle) {
        stepsToShow++;
      } else {
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep =
        widget.productTour.steps[index] as AnnouncementProductTourStep;
    return SingleChildScrollView(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 100),
        curve: Curves.decelerate,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOutCirc,
              switchOutCurve: Curves.easeInOutCirc,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final inAnimation = Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: const Offset(0.0, 0.0))
                    .animate(animation);
                final outAnimation = Tween<Offset>(
                        begin: const Offset(-1.0, 0.0),
                        end: const Offset(0.0, 0.0))
                    .animate(animation);
                if (child.key == ValueKey(index)) {
                  return ClipRect(
                    child: SlideTransition(
                      position: inAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: child,
                      ),
                    ),
                  );
                } else {
                  return ClipRect(
                    child: SlideTransition(
                      position: outAnimation,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: child,
                      ),
                    ),
                  );
                }
              },
              child: AnnouncementStepPreview(
                step: currentStep,
                key: ValueKey(index),
              ),
            ),
            if (stepsToShow > 1)
              Row(
                mainAxisAlignment: initialIndex == index
                    ? MainAxisAlignment.end
                    : MainAxisAlignment.spaceBetween,
                children: [
                  if (index > initialIndex)
                    TextButton(
                        onPressed: () => setState(() => index--),
                        child: const Text('Back')),
                  if (index - initialIndex < stepsToShow - 1)
                    TextButton(
                        onPressed: () => setState(() => index++),
                        child: const Text('Next')),
                  if (index - initialIndex >= stepsToShow - 1)
                    TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Close')),
                ],
              )
          ],
        ),
      ),
    );
  }
}

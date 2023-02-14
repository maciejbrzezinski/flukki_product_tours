import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../controllers/product_tour_creator_controller.dart';
import '../models/product_tour_step_model.dart';
import 'element_with_widget_tree.dart';

class PointerBuilderOverlay extends StatefulWidget {
  final Function() closeOverlay;
  final RenderBox box;
  final Offset position;
  final String title;
  final Function() onHover;
  final ElementWithWidgetTree? Function(PointerHoverEvent event)?
      hoveredWidgetChanged;
  final ProductTourCreatorController controller;
  final ElementWithWidgetTree elementWithWidgetTree;
  final VoidCallback updateProductTour;

  const PointerBuilderOverlay(
      this.closeOverlay, this.box, this.position, this.title,
      {super.key,
      required this.onHover,
      this.hoveredWidgetChanged,
      required this.controller,
      required this.elementWithWidgetTree,
      required this.updateProductTour});

  @override
  State<PointerBuilderOverlay> createState() => _PointerBuilderOverlayState();
}

class _PointerBuilderOverlayState extends State<PointerBuilderOverlay> {
  bool pointerBuilderVisible = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (event) =>
          _showPointerBuilder(event, widget.elementWithWidgetTree),
      behavior: HitTestBehavior.translucent,
      child: MouseRegion(
        onHover: (event) {
          if (pointerBuilderVisible) {
            return;
          }
          if ((event.position.dx < widget.position.dx ||
                  event.position.dx >
                      widget.position.dx + widget.box.size.width) ||
              (event.position.dy < widget.position.dy ||
                  event.position.dy >
                      widget.position.dy + widget.box.size.height)) {
            widget.onHover();
          } else {
            final elementWithWidgetTree = widget.hoveredWidgetChanged!(event);
            var box = elementWithWidgetTree?.element.renderObject as RenderBox?;
            if (widget.box.hashCode != box?.hashCode) {
              widget.onHover();
            }
          }
        },
        child: ClipPath(
          clipper: InvertedClipper(widget.box, widget.position),
          child: Container(
            color: Colors.black.withOpacity(.5),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                    left: widget.position.dx,
                    top: widget.position.dy,
                    child: Container(
                      color: Colors.black.withOpacity(.5),
                      width: widget.box.size.width,
                      height: widget.box.size.height,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPointerBuilder(
      PointerDownEvent event, ElementWithWidgetTree elementWithWidgetTree) {
    widget.closeOverlay();
    final screenSize = MediaQuery.of(context).size;
    var leftPadding = widget.position.dx + widget.box.size.width + 16;
    if (leftPadding > screenSize.width) {
      leftPadding = widget.position.dx - 300;
    }
    if (leftPadding < 0) {
      leftPadding = widget.position.dx + (widget.box.size.width / 2) - 150;
    }
    var topPadding = widget.position.dy + widget.box.size.height;
    if (topPadding + 250 > screenSize.height) {
      topPadding -= 250;
    }
    showDialog(
        context: context,
        builder: (ctx) {
          return Padding(
            padding: EdgeInsets.only(
              left: leftPadding,
              top: topPadding,
            ),
            child: Align(
              alignment: Alignment.topLeft,
              widthFactor: .5,
              child: SizedBox(
                width: 300,
                height: 250,
                child: Material(
                  child: PointerBuilder(widget.controller,
                      elementWithWidgetTree, widget.updateProductTour),
                ),
              ),
            ),
          );
        });
  }
}

class InvertedClipper extends CustomClipper<Path> {
  RenderBox box;
  Offset position;

  InvertedClipper(this.box, this.position);

  @override
  Path getClip(Size size) {
    return Path()
      ..addRRect(RRect.fromLTRBAndCorners(
        position.dx - 4,
        position.dy - 4,
        position.dx + box.size.width + 4,
        position.dy + box.size.height + 4,
        topLeft: const Radius.circular(4),
        bottomLeft: const Radius.circular(4),
        bottomRight: const Radius.circular(4),
        topRight: const Radius.circular(4),
      ))
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..fillType = PathFillType.evenOdd
      ..close();
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class PointerBuilder extends StatefulWidget {
  final ProductTourCreatorController controller;
  final ElementWithWidgetTree elementWithWidgetTree;
  final VoidCallback updateProductTour;

  const PointerBuilder(
      this.controller, this.elementWithWidgetTree, this.updateProductTour,
      {super.key});

  @override
  State<PointerBuilder> createState() => _PointerBuilderState();
}

class _PointerBuilderState extends State<PointerBuilder> {
  PointerAction nextStepAction = PointerAction.next;
  final captionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              TextField(
                controller: captionController,
                minLines: 2,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: 'Describe what you are showing there',
                    border:
                        OutlineInputBorder(borderSide: BorderSide(width: .2))),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text('How user should move to the next step'),
              const SizedBox(
                height: 8,
              ),
              DropdownButtonFormField<PointerAction>(
                  value: nextStepAction,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderSide: BorderSide(width: .2))),
                  items: const [
                    DropdownMenuItem(
                      value: PointerAction.next,
                      child: Text('Click next button'),
                    ),
                    DropdownMenuItem(
                      value: PointerAction.click,
                      child: Text('Click on the element'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(
                        () => nextStepAction = value ?? PointerAction.next);
                  }),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel')),
              TextButton(
                  onPressed: () {
                    widget.controller.addPointer(captionController.text,
                        widget.elementWithWidgetTree, nextStepAction);
                    widget.updateProductTour();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Ok')),
            ],
          )
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flukki_product_tours/src/controllers/context_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'constants.dart';
import 'src/controllers/flukki_controller.dart';
import 'src/controllers/product_tour_creator_controller.dart';

import 'src/controllers/product_tours_controller.dart';
import 'src/models/product_tour_model.dart';
import 'src/models/product_tour_step_model.dart';
import 'src/widgets/announcement_builder.dart';
import 'src/widgets/element_with_widget_tree.dart';
import 'src/widgets/overlay_with_hole.dart';

class Flukki {
  static final Flukki instance = Flukki._();

  Flukki._();

  /// This method is responsible for initialization of the whole ecosystem
  /// When initialization is done, yours will be able to see product tours.
  /// [key] is a personal key from flukki.com
  /// [appName] is a unique app name, important when you have more than one app
  /// [callbacks] is a list of functions, that may be used when building announcements
  Future<void> initialize(
      {required String key,
      required String appName,
      Map<String, void Function()>? callbacks}) async {
    assert(const bool.fromEnvironment('flutter.memory_allocations') == true,
        'Environment variable not set. Add <flutter.memory_allocations=true> environment variable. Your run method should look like this "--dart-define=flutter.memory_allocations=true"');
    MemoryAllocations.instance.addListener((event) {
      if (event.object is Element) {
        if (event is ObjectCreated) {
          ContextController.instance.addElement(event.object as Element);
        } else if (event is ObjectDisposed) {
          ContextController.instance.removeElement(event.object as Element);
        }
      }
    });
    WidgetsBinding.instance.addPersistentFrameCallback((timeStamp) {
      if (ContextController.instance.flushAwaiting()) {
        ContextController.instance.performCheck();
      }
    });
    return FlukkiController.instance
        .initialize(key: key, appName: appName, callbacks: callbacks);
  }

  /// A method to turn on product tours builder
  void turnOnBuilder() => FlukkiController.instance.turnOnBuilder();
}

/// Widget, that gives possibility to create and display product tours
class FlukkiProductTour extends StatefulWidget {
  final Widget child;

  const FlukkiProductTour({super.key, required this.child});

  @override
  State<FlukkiProductTour> createState() => _FlukkiProductTourState();
}

class _FlukkiProductTourState extends State<FlukkiProductTour> {
  static OverlayEntry? lastEntry;
  static Element? lastElement;
  static int? lastWidgetIndex;
  static ProductTourCreatorController? productTourCreatorController;

  static late BuildContext contextToExplore;
  bool isAddingPointerStep = false;
  final formKey = GlobalKey<FormState>();
  bool saving = false;
  StreamSubscription? streamSubscription;
  bool creationModeEnabled = false;

  @override
  void initState() {
    super.initState();
    streamSubscription =
        FlukkiController.instance.onCreationModeChanged.listen((event) {
      if (mounted) {
        setState(() => creationModeEnabled = event);
      }
    });
  }

  @override
  void dispose() {
    streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final child = _MyRecognizableWrapper(child: widget.child);

    productTourCreatorController
        ?.registerEditorRefresher(() => setState(() {}));
    contextToExplore = context;
    ContextController.instance.buildContext = contextToExplore;

    if (!FlukkiController.instance.isInBuilderMode) {
      return child;
    }

    return Scaffold(
      body: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MouseRegion(
                hitTestBehavior: HitTestBehavior.translucent,
                onHover: !isAddingPointerStep
                    ? null
                    : (event) => _pointWidget(event, context),
                child: Builder(
                  builder: (BuildContext ctx) {
                    contextToExplore = ctx;
                    ContextController.instance.buildContext = contextToExplore;
                    return child;
                  },
                ),
              ),
            ),
            if (productTourCreatorController == null)
              _ListOfProductTours(onTap: (productTour) {
                productTourCreatorController =
                    ProductTourCreatorController(productTour: productTour);
                setState(() {});
              }, createNewProductTour: () {
                productTourCreatorController = ProductTourCreatorController();
                setState(() {});
              }),
            if (productTourCreatorController != null)
              _ProductTourEditor(
                saving: saving,
                controller: productTourCreatorController!,
                turnOnPointer: () => setState(() {
                  isAddingPointerStep = true;
                }),
                turnOffPointer: () => setState(() {
                  isAddingPointerStep = false;
                }),
                contextToExplore: contextToExplore,
                finishEditingWithoutSaving: () {
                  setState(() {
                    productTourCreatorController = null;
                  });
                },
                isAddingPointerStep: isAddingPointerStep,
                saveProductTour: _saveProductTour,
              )
          ],
        ),
      ),
    );
  }

  Future<void> _saveProductTour() async {
    if (formKey.currentState?.validate() == true) {
      setState(() => saving = true);
      await productTourCreatorController!.save();
      productTourCreatorController = null;
      setState(() => saving = false);
      if (lastEntry != null) {
        lastEntry!.remove();
        lastEntry = null;
      }
    }
  }

  void _pointWidget(PointerHoverEvent event, BuildContext context) {
    if (lastEntry != null) {
      lastEntry!.remove();
      lastEntry = null;
    }
    lastWidgetIndex = null;
    ElementWithWidgetTree? elementWithWidgetTree =
        ContextController.instance.getMatchingElement(event.position);
    if (elementWithWidgetTree != null) {
      lastElement = elementWithWidgetTree.element;
      var box = elementWithWidgetTree.element.renderObject as RenderBox;
      var position = box.localToGlobal(Offset.zero);
      if (lastElement == elementWithWidgetTree.element &&
          lastWidgetIndex != elementWithWidgetTree.index) {
        elementWithWidgetTree.index =
            lastWidgetIndex ?? elementWithWidgetTree.index;
      }
      lastWidgetIndex = elementWithWidgetTree.index;
      _pointWidgetCreator(context, box, position, elementWithWidgetTree);
    }
  }

  _updateProductTourBuilder() => setState(() {
        isAddingPointerStep = false;
      });

  _pointWidgetCreator(BuildContext context, RenderBox box, Offset position,
      ElementWithWidgetTree elementWithWidgetTree) {
    lastEntry = OverlayEntry(
        builder: (ctx) => PointerBuilderOverlay(
              () {
                lastEntry?.remove();
                lastEntry = null;
              },
              box,
              position,
              'Describe your pointer',
              updateProductTour: _updateProductTourBuilder,
              onHover: () {
                if (lastEntry != null) {
                  lastEntry!.remove();
                  lastEntry = null;
                }
              },
              hoveredWidgetChanged: (event) =>
                  ContextController.instance.getMatchingElement(event.position),
              controller: productTourCreatorController!,
              elementWithWidgetTree: elementWithWidgetTree,
            ));
    Overlay.of(context).insert(lastEntry!);
  }
}

class _ListOfProductTours extends StatefulWidget {
  final Function(ProductTour productTour) onTap;
  final Function() createNewProductTour;

  const _ListOfProductTours(
      {required this.onTap, required this.createNewProductTour});

  @override
  State<_ListOfProductTours> createState() => _ListOfProductToursState();
}

class _ListOfProductToursState extends State<_ListOfProductTours> {
  List<String> duringDeletionIds = [];
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final productTours = ProductToursController.instance.productTours;
    return Container(
      color: FlukkiConstants.backgroundColor,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
        child: Row(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (productTours.isEmpty)
              _EmptyProductToursWidget(
                  createNewProductTour: widget.createNewProductTour),
            if (productTours.isNotEmpty)
              Expanded(
                child: Scrollbar(
                  controller: scrollController,
                  child: ListView.builder(
                      itemCount: productTours.length,
                      controller: scrollController,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (ctx, index) {
                        final productTour = productTours[index];
                        return InkWell(
                          onTap: () => widget.onTap(productTour),
                          child: Padding(
                            padding: EdgeInsets.only(
                                right: index == productTours.length - 1
                                    ? 0
                                    : 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                  color: FlukkiConstants.cardColor,
                                  borderRadius: BorderRadius.circular(
                                      FlukkiConstants.borderRadius)),
                              width: 150,
                              height: 150,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(productTour.name ??
                                        productTour.id ??
                                        'Product tour'),
                                    if (duringDeletionIds
                                        .contains(productTour.id))
                                      const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 3,
                                        ),
                                      )
                                    else
                                      ElevatedButton(
                                        onPressed: () async {
                                          setState(() {
                                            duringDeletionIds
                                                .add(productTour.id!);
                                          });
                                          await ProductToursController.instance
                                              .removeProductTour(productTour);
                                          if (mounted) {
                                            setState(() {
                                              duringDeletionIds
                                                  .remove(productTour.id!);
                                            });
                                          }
                                        },
                                        style:
                                            FlukkiConstants.regularButtonStyle,
                                        child: const Text('Delete'),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (productTours.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: widget.createNewProductTour,
                      label: const Text('Create new'),
                      icon: const Icon(Icons.add),
                      style: FlukkiConstants.accentButtonStyle,
                    ),
                  ElevatedButton(
                      onHover: (b) {},
                      onPressed: () {
                        FlukkiController.instance.turnOffBuilder();
                      },
                      style: FlukkiConstants.regularButtonStyle,
                      child: const Text('Close builder')),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyProductToursWidget extends StatelessWidget {
  final Function() createNewProductTour;

  const _EmptyProductToursWidget({required this.createNewProductTour});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if (screenWidth > 740)
            Stack(
              children: [
                Container(
                  width: 220,
                  // height: 150,
                  decoration: BoxDecoration(
                    color: FlukkiConstants.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Positioned(
                  bottom: 40,
                  left: 16,
                  child: Container(
                    width: 160,
                    height: 16,
                    decoration: BoxDecoration(
                      color: FlukkiConstants.cardPlaceholderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FlukkiConstants.cardPlaceholderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 56,
                  child: Container(
                    width: 32,
                    height: 4,
                    decoration: BoxDecoration(
                      color: FlukkiConstants.cardPlaceholderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 64,
                  left: 16,
                  child: Container(
                    width: 48,
                    height: 8,
                    decoration: BoxDecoration(
                      color: FlukkiConstants.cardPlaceholderColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: FlukkiConstants.cardPlaceholderColor,
                      borderRadius: BorderRadius.circular(360),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(
            width: 16,
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 500),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You have no product tours yet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Expanded(
                      child: Row(
                        children: const [
                          Expanded(
                            child: Text(
                              'Product tour builder is inside of your app and after save, the newly created product tour will be delivered to all app users',
                              overflow: TextOverflow.fade,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: createNewProductTour,
                      label: const Text('Create new'),
                      icon: const Icon(Icons.add),
                      style: FlukkiConstants.accentButtonStyle,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductTourEditor extends StatefulWidget {
  final ProductTourCreatorController controller;
  final VoidCallback turnOnPointer;
  final VoidCallback turnOffPointer;
  final BuildContext contextToExplore;
  final VoidCallback finishEditingWithoutSaving;
  final bool isAddingPointerStep;
  final VoidCallback saveProductTour;
  final bool saving;

  const _ProductTourEditor(
      {required this.controller,
      required this.turnOnPointer,
      required this.turnOffPointer,
      required this.contextToExplore,
      required this.finishEditingWithoutSaving,
      required this.isAddingPointerStep,
      required this.saveProductTour,
      required this.saving});

  @override
  State<_ProductTourEditor> createState() => _ProductTourEditorState();
}

class _ProductTourEditorState extends State<_ProductTourEditor> {
  final nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController.text = widget.controller.productTour.name ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: FlukkiConstants.backgroundColor,
      height: 200,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24),
        child: widget.saving
            ? const Center(
                child: SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: FlukkiConstants.accentButtonBackgroundColor,
                    )),
              )
            : Row(
                children: [
                  SizedBox(
                    width: 150,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 50),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: child,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: Container(
                              key: ValueKey<String>(
                                  'Is adding pointer: ${widget.isAddingPointerStep}'),
                              child: widget.isAddingPointerStep
                                  ? InkWell(
                                      onTap: widget.turnOffPointer,
                                      child: Container(
                                        color: FlukkiConstants
                                            .errorBackgroundColor,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.close,
                                              size: 32,
                                              color: FlukkiConstants
                                                  .errorTextColor,
                                            ),
                                            Text(
                                              'Cancel',
                                              style: TextStyle(
                                                color: FlukkiConstants
                                                    .errorTextColor,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                              onPressed: widget.turnOnPointer,
                                              style: FlukkiConstants
                                                  .regularButtonStyle,
                                              child: const Text(
                                                'Add pointer',
                                                textAlign: TextAlign.center,
                                              )),
                                        ),
                                        const SizedBox(
                                          height: 8,
                                        ),
                                        Expanded(
                                          child: ElevatedButton(
                                              onPressed:
                                                  _showAnnouncementBuilder,
                                              style: FlukkiConstants
                                                  .regularButtonStyle,
                                              child: const Text(
                                                'Add announcement',
                                                textAlign: TextAlign.center,
                                              )),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  Expanded(
                      child: _ProductTourSteps(
                    steps: widget.controller.productTour.steps,
                    controller: widget.controller,
                    setState: () => setState(() {}),
                  )),
                  const SizedBox(
                    width: 16,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Tooltip(
                          message: widget.controller.productTour.steps.isEmpty
                              ? 'Add some steps to be able to save product tour'
                              : '',
                          child: ElevatedButton.icon(
                            onPressed: widget
                                    .controller.productTour.steps.isEmpty
                                ? null
                                : () {
                                    if (widget.controller.productTour.name ==
                                            null ||
                                        widget.controller.productTour.name!
                                            .isEmpty) {
                                      _showNameDialog(context);
                                    } else {
                                      widget.saveProductTour();
                                    }
                                  },
                            label: const Text('Save'),
                            icon: const Icon(Icons.save),
                            style: FlukkiConstants.accentButtonStyle,
                          ),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                            onPressed: () => FlukkiController.instance
                                .turnOnTestMode(widget.controller.productTour),
                            style: FlukkiConstants.regularButtonStyle,
                            child: const Text('Test this product tour')),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => widget.finishEditingWithoutSaving(),
                          style: FlukkiConstants.regularButtonStyle,
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
      ),
    );
  }

  void _showNameDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (ctx) {
          final formKey = GlobalKey<FormState>();
          return SizedBox(
            width: 300,
            height: 200,
            child: SimpleDialog(
              children: [
                Column(
                  children: [
                    const Text('Give your product tour some name'),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Form(
                        key: formKey,
                        child: TextFormField(
                          onChanged: (newName) =>
                              widget.controller.setProductTourName(newName),
                          validator: (value) => value == null || value.isEmpty
                              ? 'Can\'t be empty'
                              : null,
                          decoration: FlukkiConstants.textInputDecoration(
                              name: 'Product tour\'s name'),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: TextButton(
                          onPressed: () {
                            if (formKey.currentState?.validate() == true) {
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Ok')),
                    )
                  ],
                )
              ],
            ),
          );
        }).then((value) => widget.saveProductTour());
  }

  Future<void> _showAnnouncementBuilder() async {
    final newStep = widget.controller.addAnnouncement();
    await showDialog(
        context: widget.contextToExplore,
        useSafeArea: true,
        builder: (ctx) {
          return Material(
              child: Dialog(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 500, maxWidth: 700),
              child: AnnouncementBuilder(newStep, widget.controller),
            ),
          ));
        });
  }
}

class _ProductTourSteps extends StatelessWidget {
  final List<ProductTourStep> steps;
  final ProductTourCreatorController controller;
  final VoidCallback setState;
  final scrollController = ScrollController();

  _ProductTourSteps(
      {required this.steps, required this.controller, required this.setState});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
      controller: scrollController,
      child: ReorderableListView(
        scrollController: scrollController,
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        onReorder: controller.reorder,
        children: steps.map((step) {
          if (step is PointerProductTourStep) {
            final pointerAction = step.pointerAction;
            return SizedBox(
              key: ValueKey(step),
              width: 150,
              height: 200,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          step.caption,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      'Progress action',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(_pointerActionDescription(pointerAction)),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 32),
                      child: Tooltip(
                        message: controller.productTour.steps.length == 1
                            ? 'You can\'t remove the last step'
                            : '',
                        child: ElevatedButton(
                            style: FlukkiConstants.regularButtonStyle,
                            onPressed: controller.productTour.steps.length == 1
                                ? null
                                : () {
                                    controller.removeStep(step);
                                    setState();
                                  },
                            child: const Text('Delete')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (step is AnnouncementProductTourStep) {
            return SizedBox(
              key: ValueKey(step),
              width: 150,
              height: 150,
              child: Card(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(step.displayStyle.name),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 32.0),
                      child: ElevatedButton(
                          style: FlukkiConstants.regularButtonStyle,
                          onPressed: () {
                            controller.removeStep(step);
                            setState();
                          },
                          child: const Text('Delete')),
                    ),
                  ],
                ),
              ),
            );
          }
          return Container(
            key: ValueKey(step),
          );
        }).toList(),
      ),
    );
  }

  String _pointerActionDescription(PointerAction pointerAction) {
    switch (pointerAction) {
      case PointerAction.next:
        return 'Click next button';
      case PointerAction.click:
        return 'Click on the element';
    }
  }
}

class _MyRecognizableWrapper extends StatelessWidget {
  final Widget child;

  const _MyRecognizableWrapper({required this.child});

  @override
  Widget build(BuildContext context) => child;
}
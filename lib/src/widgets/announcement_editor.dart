import 'package:flutter/material.dart';

import '../controllers/flukki_controller.dart';
import '../controllers/product_tour_creator_controller.dart';
import '../models/product_tour_step_model.dart';
import 'choose_image_widget.dart';
import 'color_picker_with_title.dart';
import 'display_style_picker.dart';
import 'page_widgets/button_widget.dart';
import 'page_widgets/image_widget.dart';
import 'page_widgets/text_widget.dart';
import 'textfield_with_label.dart';

class RegularPageEditForm extends StatefulWidget {
  final AnnouncementProductTourStep currentStep;
  final ProductTourCreatorController controller;

  const RegularPageEditForm(
      {required this.currentStep, required this.controller, Key? key})
      : super(key: key);

  @override
  State<RegularPageEditForm> createState() => _RegularPageEditFormState();
}

class _RegularPageEditFormState extends State<RegularPageEditForm> {
  final scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    widget.currentStep.widgets.sort(
      (a, b) => a.index.compareTo(b.index),
    );
    final List<Widget> editorWidgets = widget.currentStep.widgets.map((wdgt) {
      if (wdgt is TextWidget) {
        return RemoveableAndOrderableWidget(
          currentStep: widget.currentStep,
          widgetsCount: widget.currentStep.widgets.length,
          widgetIndex: wdgt.index,
          editController: widget.controller,
          child: TextFieldWithLabel(
            label: 'Text',
            initialValue: wdgt.value,
            onChanged: (value) => widget.controller.setTextWidgetValue(
                step: widget.currentStep,
                widgetIndex: wdgt.index,
                value: value),
            textStyling: wdgt.textStyling,
            onStyleChanged: (TextStyling? value) => widget.controller
                .setTextWidgetStyling(
                    step: widget.currentStep,
                    widgetIndex: wdgt.index,
                    style: value),
          ),
        );
      } else if (wdgt is ButtonWidget) {
        return RemoveableAndOrderableWidget(
          currentStep: widget.currentStep,
          widgetsCount: widget.currentStep.widgets.length,
          widgetIndex: wdgt.index,
          editController: widget.controller,
          child: ButtonEditor(
            currentStep: widget.currentStep,
            controller: widget.controller,
            widgetIndex: wdgt.index,
            callback: wdgt.callbackKey,
            callbackTitle: wdgt.title,
          ),
        );
      } else if (wdgt is ImageWidget) {
        return RemoveableAndOrderableWidget(
          currentStep: widget.currentStep,
          widgetsCount: widget.currentStep.widgets.length,
          widgetIndex: wdgt.index,
          editController: widget.controller,
          child: ChooseImageWidget(
            controller: widget.controller,
            widgetIndex: wdgt.index,
            address: wdgt.address,
            currentStep: widget.currentStep,
          ),
        );
      } else {
        return const SizedBox();
      }
    }).toList();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: editorWidgets
                ..insert(
                    0,
                    ColorPickerWithTitle(
                        currentStep: widget.currentStep,
                        editController: widget.controller))
                ..insert(
                    0,
                    DisplayStylePicker(
                        currentStep: widget.currentStep,
                        editController: widget.controller))
                ..insert(
                    2,
                    NewWidgetButton(
                      controller: widget.controller,
                      currentStep: widget.currentStep,
                    ))
                ..add(ActionButtons(widget.controller, widget.currentStep))),
        ),
      ),
    );
  }
}

class NewWidgetButton extends StatelessWidget {
  final ProductTourCreatorController controller;
  final AnnouncementProductTourStep currentStep;

  const NewWidgetButton(
      {super.key, required this.controller, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'text',
          child: Text('Text'),
        ),
        PopupMenuItem(
          value: 'button',
          child: Text('Button'),
        ),
        PopupMenuItem(
          value: 'image',
          child: Text('Image'),
        ),
      ],
      onSelected: (type) =>
          controller.addWidgetToCurrentPage(type: type, step: currentStep),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.all(Radius.circular(4))),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            children: [
              Text(
                'Add widget',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.white),
              ),
              const Icon(
                Icons.add,
                size: 42,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ButtonEditor extends StatefulWidget {
  final ProductTourCreatorController controller;
  final String? callback;
  final String? callbackTitle;
  final int widgetIndex;
  final AnnouncementProductTourStep currentStep;

  const ButtonEditor(
      {super.key,
      required this.controller,
      required this.callback,
      required this.widgetIndex,
      this.callbackTitle,
      required this.currentStep});

  @override
  State<ButtonEditor> createState() => _ButtonEditorState();
}

class _ButtonEditorState extends State<ButtonEditor> {
  @override
  Widget build(BuildContext context) {
    final callbacks = FlukkiController.instance.callbacks;
    if (callbacks.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
        widget.controller.setButtonWidgetCallbackTitle(
            step: widget.currentStep,
            widgetIndex: widget.widgetIndex,
            value: null);
        widget.controller.setButtonWidgetCallbackKey(
            step: widget.currentStep,
            widgetIndex: widget.widgetIndex,
            newKey: null);
      });
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
              'No button actions uploaded yet. Run your configured app in debug mode and you will see possible actions here'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: DropdownButtonFormField<String>(
                focusColor: Colors.transparent,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(), labelText: 'Choose action'),
                value: widget.callback,
                onChanged: (newKey) => widget.controller
                    .setButtonWidgetCallbackKey(
                        step: widget.currentStep,
                        widgetIndex: widget.widgetIndex,
                        newKey: newKey),
                items: callbacks.keys
                    .map<DropdownMenuItem<String>>((key) => DropdownMenuItem(
                          value: key,
                          child: Text(key),
                        ))
                    .toList()
                  ..insert(
                      0,
                      const DropdownMenuItem(
                          value: null, child: Text('No action'))),
              ),
            ),
            if (widget.callback != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: TextFieldWithLabel(
                    label: 'Caption',
                    onChanged: (newCaption) => widget.controller
                        .setButtonWidgetCallbackTitle(
                            step: widget.currentStep,
                            widgetIndex: widget.widgetIndex,
                            value: newCaption),
                    initialValue: widget.callbackTitle),
              ),
          ],
        ),
      ),
    );
  }
}

class ActionButtons extends StatelessWidget {
  final ProductTourCreatorController editController;
  final AnnouncementProductTourStep currentStep;

  const ActionButtons(this.editController, this.currentStep, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => _saveProductTour(context),
              child: const Text('Save'),
            ),
          ),
          const SizedBox(
            width: 32.0,
          ),
          Expanded(
            child: TextButton(
              onPressed: () {
                editController.cancelStepEdition(currentStep);
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }

  _saveProductTour(BuildContext context) async {
    editController.refreshEditor();
    Navigator.of(context).pop();
  }
}

class RemoveableAndOrderableWidget extends StatelessWidget {
  final ProductTourCreatorController editController;
  final AnnouncementProductTourStep currentStep;
  final Widget child;
  final int widgetIndex;
  final int widgetsCount;

  const RemoveableAndOrderableWidget(
      {required this.editController,
      required this.currentStep,
      required this.child,
      required this.widgetIndex,
      required this.widgetsCount,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(child: child),
        Column(
          children: [
            IconButton(
                onPressed: widgetIndex == 0
                    ? null
                    : () => editController.switchWidgetIndex(
                        currentStep, widgetIndex, -1),
                icon: const Icon(Icons.arrow_upward)),
            IconButton(
                onPressed: widgetIndex == widgetsCount - 1
                    ? null
                    : () => editController.switchWidgetIndex(
                        currentStep, widgetIndex, 1),
                icon: const Icon(Icons.arrow_downward)),
          ],
        ),
        IconButton(
            onPressed: () => editController.removeWidgetFromCurrentPage(
                currentStep, widgetIndex),
            icon: const Icon(Icons.delete_outline))
      ],
    );
  }
}

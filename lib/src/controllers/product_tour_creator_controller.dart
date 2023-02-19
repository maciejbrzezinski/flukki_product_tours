import 'package:flutter/material.dart';

import '../api/flukki_api.dart';
import '../models/product_tour_model.dart';
import '../models/product_tour_step_model.dart';
import '../widgets/element_with_widget_tree.dart';
import 'drop_down_controller.dart';
import 'flukki_controller.dart';
import 'local_storage_controller.dart';
import 'product_tours_controller.dart';
import '../widgets/drop_down.dart';
import '../widgets/page_widgets/abstract_page_widget.dart';
import '../widgets/page_widgets/button_widget.dart';
import '../widgets/page_widgets/image_widget.dart';
import '../widgets/page_widgets/text_widget.dart';

class ProductTourCreatorController {
  late ProductTour _productTour;
  int currentIndex = 0;

  ProductTour get productTour => _productTour;

  ProductTourCreatorController({ProductTour? productTour}) {
    _productTour = productTour?.clone() ?? ProductTour();
  }

  PointerProductTourStep addPointer(String caption,
      ElementWithWidgetTree elementWithWidgetTree, PointerAction action) {
    return _productTour.addStep(PointerProductTourStep(
            _productTour.stepsCount,
            caption,
            elementWithWidgetTree.widgetTree.toString(),
            action,
            elementWithWidgetTree.index,
            widgetName: elementWithWidgetTree.widgetName))
        as PointerProductTourStep;
  }

  AnnouncementProductTourStep addAnnouncement() {
    return _productTour.addStep(
        AnnouncementProductTourStep(_productTour.stepsCount, widgetsList: [
      const TextWidget(value: 'Title', index: 0, textStyling: TextStyling.h2),
      const TextWidget(value: 'Describe your value', index: 1),
    ])) as AnnouncementProductTourStep;
  }

  Future<void> save() async {
    final apiKey = FlukkiController.instance.apiKey!;
    final appName = FlukkiController.instance.appId!;

    await _saveImages(
        appName: appName, apiKey: apiKey, productTour: productTour);

    final id = await FlukkiApi.saveProductTour(
        appName: appName, apiKey: apiKey, productTour: productTour);
    if (productTour.id == null) {
      if (id != null) {
        productTour.id = id;
        await FlukkiApi.saveProductTour(
            appName: appName, apiKey: apiKey, productTour: productTour);
      }
    }

    ProductToursController.instance.replaceProductTour(productTour);

    LocalStorageController.saveProductTour(productTour);
    refreshEditor();
  }

  removeStep(ProductTourStep stepToDelete) {
    final stepsLength = _productTour.steps.length;
    if (stepsLength == 1) {
      _productTour.steps.clear();
    } else {
      _productTour.steps
          .removeWhere((element) => element.index == stepToDelete.index);
      for (var step in _productTour.steps) {
        if (step.index > stepToDelete.index) {
          step.index--;
        }
      }
    }
    _editorRefresher!();
  }

  void switchWidgetIndex(
      AnnouncementProductTourStep step, int widgetIndex, int indexDifference) {
    final currentWidget = step.widgets[widgetIndex];
    final affectedWidget = step.widgets[widgetIndex + indexDifference];

    _changeIndex(
        currentWidget, step, widgetIndex, indexDifference + widgetIndex);
    _changeIndex(
        affectedWidget, step, widgetIndex + indexDifference, widgetIndex);

    step.widgets.sort((a, b) => a.index.compareTo(b.index));
    _refreshAnnouncementForm();
  }

  _changeIndex(AnnouncementWidget widget, AnnouncementProductTourStep step,
      int originalIndex, int newIndex) {
    if (widget is ButtonWidget) {
      step.widgets[originalIndex] = widget.copyWith(index: newIndex);
    }
    if (widget is TextWidget) {
      step.widgets[originalIndex] = widget.copyWith(index: newIndex);
    }
    if (widget is ImageWidget) {
      step.widgets[originalIndex] = widget.copyWith(index: newIndex);
    }
  }

  void setTextWidgetValue(
      {required AnnouncementProductTourStep step,
      required int widgetIndex,
      required String? value}) {
    TextWidget textWidget = step.widgets[widgetIndex] as TextWidget;
    textWidget = textWidget.copyWith(value: () => value);
    step.widgets[widgetIndex] = textWidget;
    _refreshAnnouncementForm();
  }

  void setTextWidgetStyling(
      {required AnnouncementProductTourStep step,
      required int widgetIndex,
      required TextStyling? style}) {
    TextWidget textWidget = step.widgets[widgetIndex] as TextWidget;
    textWidget = textWidget.copyWith(textStyling: () => style);
    step.widgets[widgetIndex] = textWidget;
    _refreshAnnouncementForm();
  }

  void setButtonWidgetCallbackTitle(
      {required AnnouncementProductTourStep step,
      required int widgetIndex,
      required String? value}) {
    ButtonWidget buttonWidget = step.widgets[widgetIndex] as ButtonWidget;
    buttonWidget = buttonWidget.copyWith(title: () => value);
    step.widgets[widgetIndex] = buttonWidget;
    _refreshAnnouncementForm();
  }

  void setButtonWidgetCallbackKey(
      {required AnnouncementProductTourStep step,
      required int widgetIndex,
      required String? newKey}) {
    ButtonWidget buttonWidget = step.widgets[widgetIndex] as ButtonWidget;
    buttonWidget = buttonWidget.copyWith(callbackKey: () => newKey);

    if (newKey == null) {
      buttonWidget = buttonWidget.copyWith(title: () => null);
    } else if (buttonWidget.title == null) {
      buttonWidget = buttonWidget.copyWith(title: () => 'Let the magic happen');
    }
    step.widgets[widgetIndex] = buttonWidget;
    _refreshAnnouncementForm();
  }

  addWidgetToCurrentPage(
      {required String type, required AnnouncementProductTourStep step}) {
    step.widgets.add(_widgetTypeToWidget(type, step.widgets.length));
    _refreshAnnouncementForm();
  }

  AnnouncementWidget _widgetTypeToWidget(String type, int index) {
    if (type == 'text') {
      return TextWidget(
        index: index,
        value: 'New text',
      );
    } else if (type == 'button') {
      return ButtonWidget(index: index);
    } else if (type == 'image') {
      return ImageWidget(
        index: index,
        address:
            'https://firebasestorage.googleapis.com/v0/b/flukki-web.appspot.com/o/appImages%2Fflukki_logo.png?alt=media',
      );
    }
    return TextWidget(
      index: index,
      value: 'New text',
    );
  }

  removeWidgetFromCurrentPage(
      AnnouncementProductTourStep currentStep, int widgetIndex) {
    currentStep.widgets.removeAt(widgetIndex);
    _refreshAnnouncementForm();
  }

  void setCurrentPageBackgroundColor(
      AnnouncementProductTourStep step, Color colorValue) {
    step.backgroundColor = colorValue;
    _refreshAnnouncementForm();
  }

  setCurrentPageDisplayStyle(
      AnnouncementProductTourStep step, DisplayStyle newStyle) {
    step.displayStyle = newStyle;
    _refreshAnnouncementForm();
  }

  void Function()? _annouoncementFormRefresher;
  void Function()? _editorRefresher;

  void registerAnnouncementFormRefresher(void Function() refresh) {
    _annouoncementFormRefresher = refresh;
  }

  void registerEditorRefresher(void Function() refresh) {
    _editorRefresher = refresh;
  }

  void _refreshAnnouncementForm() => _annouoncementFormRefresher == null
      ? null
      : _annouoncementFormRefresher!();

  void refreshEditor() => _editorRefresher == null ? null : _editorRefresher!();

  cancelStepEdition(AnnouncementProductTourStep currentStep) {
    if (currentStep.isNew) {
      removeStep(currentStep);
    } else {
      //todo: restoring values before edition was done
    }
  }

  setProductTourName(String? newName) {
    _productTour.name = newName;
    refreshEditor();
  }

  void reorder(int oldIndex, int newIndex) {
    final steps = productTour.steps;
    final int stepsLength = productTour.stepsCount;
    if (newIndex > stepsLength) newIndex = stepsLength;
    if (oldIndex < newIndex) newIndex--;
    steps.insert(newIndex, steps.removeAt(oldIndex));
    for (int i = 0; i < stepsLength; i++) {
      steps[i].index = i;
    }
    refreshEditor();
  }

  _saveImages(
      {required String appName,
      required String apiKey,
      required ProductTour productTour}) async {
    for (final step in productTour.steps) {
      if (step is AnnouncementProductTourStep) {
        for (var widget in step.widgets) {
          if (widget is ImageWidget && widget.photoBytes != null) {
            final imageAddress = await FlukkiApi.uploadImage(widget);
            if (imageAddress != null) {
              step.replaceWidget(widget.copyWith(address: () => imageAddress));
            }
          }
        }
      }
    }
  }

  void pickImage(AnnouncementProductTourStep step, int widgetIndex,
      BuildContext context) async {
    final SelectedFile? file = await showDialog(
        context: context,
        builder: (ctx) {
          return DragDropImage();
        });
    if (file == null) return;
    var imageWidget = step.widgets[widgetIndex] as ImageWidget;
    imageWidget = imageWidget.copyWith(
        photoBytes: file.bytes, address: () => null, fileName: file.fileName);

    step.widgets[widgetIndex] = imageWidget;
    _refreshAnnouncementForm();
  }
}

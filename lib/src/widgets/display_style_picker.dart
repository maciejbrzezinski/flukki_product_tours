import 'package:flutter/material.dart';

import '../controllers/product_tour_creator_controller.dart';
import '../models/product_tour_step_model.dart';

class DisplayStylePicker extends StatelessWidget {
  final AnnouncementProductTourStep currentStep;
  final ProductTourCreatorController editController;

  const DisplayStylePicker(
      {super.key, required this.currentStep, required this.editController});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<DisplayStyle>(
      focusColor: Colors.transparent,
      decoration: const InputDecoration(
          border: OutlineInputBorder(), labelText: 'Page display style'),
      value: currentStep.displayStyle,
      onChanged: (newStyle) =>
          editController.setCurrentPageDisplayStyle(currentStep, newStyle!),
      items: const [
        DropdownMenuItem(
          value: DisplayStyle.bottomSheet,
          child: Text('Bottom sheet'),
        ),
        DropdownMenuItem(
          value: DisplayStyle.popup,
          child: Text('Popup'),
        ),
        DropdownMenuItem(
          value: DisplayStyle.page,
          child: Text('Page'),
        ),
      ],
    );
  }
}

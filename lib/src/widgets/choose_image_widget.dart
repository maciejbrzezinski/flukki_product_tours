import 'package:flutter/material.dart';

import '../controllers/product_tour_creator_controller.dart';
import '../models/product_tour_step_model.dart';

class ChooseImageWidget extends StatelessWidget {
  final ProductTourCreatorController controller;
  final AnnouncementProductTourStep currentStep;
  final int widgetIndex;
  final String? address;

  const ChooseImageWidget(
      {super.key,
      required this.controller,
      this.address,
      required this.widgetIndex,
      required this.currentStep});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () =>
                controller.pickImage(currentStep, widgetIndex, context),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    enabled: false,
                    controller: TextEditingController(text: address),
                    // onChanged: (value) =>
                    //     controller.setCurrentPageImageWidgetValue(
                    //         widgetIndex: widgetIndex, address: value),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      filled: true,
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ),
                if (address != null)
                  Image.network(
                    address!,
                    height: 48,
                    width: 48,
                    fit: BoxFit.fitHeight,
                  ),
              ],
            ),
          ),
        ),
        TextButton(
            onPressed: () =>
                controller.pickImage(currentStep, widgetIndex, context),
            child: const Text('Choose Image')),
      ],
    );
  }
}

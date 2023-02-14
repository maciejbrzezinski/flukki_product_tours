import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

import '../controllers/product_tour_creator_controller.dart';
import '../models/product_tour_step_model.dart';

class ColorPickerWithTitle extends StatelessWidget {
  final AnnouncementProductTourStep currentStep;
  final ProductTourCreatorController editController;

  const ColorPickerWithTitle(
      {super.key, required this.currentStep, required this.editController});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Background color:',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        IconButton(
          icon: Icon(
            Icons.palette,
            color: Theme.of(context).primaryColor,
          ),
          onPressed: () => showDialog<String>(
            context: context,
            builder: (BuildContext context) => Dialog(
              alignment: Alignment.centerRight,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white,
                ),
                width: 400,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.palette,
                            color: Theme.of(context).primaryColor,
                          ),
                          const Text(
                            'Select background color',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context, 'Close');
                            },
                            icon: const Icon(
                              Icons.close,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: ColorPicker(
                          pickerOrientation: PickerOrientation.portrait,
                          color: currentStep.backgroundColor ?? Colors.white,
                          onChanged: (value) =>
                              editController.setCurrentPageBackgroundColor(
                                  currentStep, value),
                          initialPicker: Picker.paletteHue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

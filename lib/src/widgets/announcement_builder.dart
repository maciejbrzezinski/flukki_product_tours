import 'package:flutter/material.dart';

import '../controllers/product_tour_creator_controller.dart';
import '../models/product_tour_step_model.dart';
import 'announcement_editor.dart';
import 'previews.dart';

class AnnouncementBuilder extends StatefulWidget {
  final AnnouncementProductTourStep currentStep;
  final ProductTourCreatorController controller;

  const AnnouncementBuilder(this.currentStep, this.controller, {super.key});

  @override
  State<AnnouncementBuilder> createState() => _AnnouncementBuilderState();
}

class _AnnouncementBuilderState extends State<AnnouncementBuilder> {
  @override
  Widget build(BuildContext context) {
    widget.controller.registerAnnouncementFormRefresher(() => setState(() {}));
    return Row(
      children: [
        Expanded(
          child: AnnouncementStepPreview(
            step: widget.currentStep,
          ),
        ),
        Expanded(
            child: RegularPageEditForm(
                currentStep: widget.currentStep,
                controller: widget.controller)),
      ],
    );
  }
}

import 'package:flutter/material.dart';

import 'page_widgets/text_widget.dart';

class TextFieldWithLabel extends StatefulWidget {
  final String label;
  final Function(String value) onChanged;
  final Function(TextStyling? value)? onStyleChanged;
  final String? initialValue;
  final TextStyling? textStyling;

  const TextFieldWithLabel(
      {Key? key,
      required this.label,
      required this.onChanged,
      this.initialValue,
      this.textStyling,
      this.onStyleChanged})
      : super(key: key);

  @override
  State<TextFieldWithLabel> createState() => _TextFieldWithLabelState();
}

class _TextFieldWithLabelState extends State<TextFieldWithLabel> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Flexible(
            child: TextFormField(
              initialValue: widget.initialValue,
              onChanged: widget.onChanged,
              decoration: InputDecoration(
                labelText: widget.label,
                hintText: 'Type some ${widget.label.toLowerCase()}',
                border: const OutlineInputBorder(),
                fillColor: Colors.white,
              ),
            ),
          ),
          if (widget.onStyleChanged != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<TextStyling?>(
                value: widget.textStyling,
                onChanged: widget.onStyleChanged,
                items: const [
                  DropdownMenuItem(
                      value: TextStyling.body, child: Text('Body')),
                  DropdownMenuItem(
                      value: TextStyling.caption, child: Text('Caption')),
                  DropdownMenuItem(value: TextStyling.h1, child: Text('H1')),
                  DropdownMenuItem(value: TextStyling.h2, child: Text('H2')),
                  DropdownMenuItem(value: TextStyling.h3, child: Text('H3')),
                  DropdownMenuItem(value: TextStyling.h4, child: Text('H4')),
                  DropdownMenuItem(value: TextStyling.h5, child: Text('H5')),
                  DropdownMenuItem(value: TextStyling.h6, child: Text('H6')),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

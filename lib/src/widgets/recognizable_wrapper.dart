import 'package:flutter/material.dart';

class MyRecognizableWrapper extends StatelessWidget {
  final Widget child;

  const MyRecognizableWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) => child;
}

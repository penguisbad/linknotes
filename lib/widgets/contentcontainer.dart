import 'package:flutter/material.dart';

class ContentContainer extends StatelessWidget {

  final Widget child;
  final double? maxWidth;

  const ContentContainer({super.key, required this.child, this.maxWidth});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Center(child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 1000000.0),
        child: child
      ))
    );
  }

}
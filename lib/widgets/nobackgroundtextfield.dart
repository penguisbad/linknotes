import 'package:flutter/material.dart';

class NoBackgroundTextField extends StatelessWidget {

  final String placeholder;
  final TextEditingController? controller;
  final bool? multiline;
  final FocusNode? focusNode;

  const NoBackgroundTextField({super.key, required this.placeholder,
   this.controller, this.multiline, this.focusNode});

  @override
  Widget build(BuildContext context) {
    return TextField(
      focusNode: focusNode,
      controller: controller,
      maxLines: (multiline != null && multiline!) ? null : 1,
      style: Theme.of(context).textTheme.displaySmall!,
      decoration: InputDecoration(
        hintText: placeholder,
        fillColor: const Color.fromRGBO(40, 40, 60, 1),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none
      ),
    );
  }

}
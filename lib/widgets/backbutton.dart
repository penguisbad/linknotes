import 'package:flutter/material.dart';

class LBackButton extends StatelessWidget {

  final VoidCallback onPressed;

  const LBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: IconButton(
        onPressed: () => onPressed(),
        icon: const Icon(Icons.arrow_back_ios_new)
      )
    );
  }

}
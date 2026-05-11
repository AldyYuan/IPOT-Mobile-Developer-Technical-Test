import 'package:flutter/material.dart';

class TextFieldTheme {
  TextFieldTheme._();

  static InputDecorationTheme get theme => InputDecorationTheme(
    filled: true,
    fillColor: const Color(0xFFF8F5F0),
    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    hintStyle: const TextStyle(color: Colors.black38),
  );
}

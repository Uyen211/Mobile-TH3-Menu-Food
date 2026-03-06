import 'package:flutter/material.dart';

/// Simple global Theme controller using a ValueNotifier.
/// Toggle with `ThemeController.toggle()` and listen via `themeMode`.
class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode = ValueNotifier(
    ThemeMode.light,
  );

  static void toggle() {
    themeMode.value = themeMode.value == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
  }
}

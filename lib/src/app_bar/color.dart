import 'dart:ui';

import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  Color linearToSrgb() {
    // var r = red / 255;
    // var g = green / 255;
    // var b = blue / 255;

    // r = (r <= 0.0031308) ? 12.92 * r : 1.055 * pow(r, 1 / 2.4) - 0.055;
    // g = (g <= 0.0031308) ? 12.92 * g : 1.055 * pow(g, 1 / 2.4) - 0.055;
    // b = (b <= 0.0031308) ? 12.92 * b : 1.055 * pow(b, 1 / 2.4) - 0.055;

    return Color.fromRGBO((r * 255).clamp(0, 255).toInt(),
        (g * 255).clamp(0, 255).toInt(), (b * 255).clamp(0, 255).toInt(), a);
  }

  Color srgbToLinear() {
    // num r = r / 255;
    // num g = green / 255;
    // num b = blue / 255;

    // r = (r <= 0.04045) ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4);
    // g = (g <= 0.04045) ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4);
    // b = (b <= 0.04045) ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4);

    return Color.fromRGBO(
        (r * 255).toInt(), (g * 255).toInt(), (b * 255).toInt(), a);
  }
}

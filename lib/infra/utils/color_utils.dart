
import 'package:flutter/material.dart';

class ColorUtils {
  static List<String> colorArray = [
    'FF9990FF',  // Light Purple
    'FFFF5723',  // Deep Orange
    'FFFF4081',  // Pink
    'FF4CAF50',  // Green
    'FF2196F3',  // Blue
    'FF9C27B0',  // Purple
    'FF00BCD4',  // Cyan
    'FF3F51B5',  // Indigo
    'FF8BC34A',  // Light Green
    'FFFFEB3B',  // Yellow
    'FF009688',  // Teal
    'FF673AB7',  // Deep Purple
    'FF795548',  // Brown
    'FF607D8B',  // Blue Grey
  ];

  // Function to convert hex (without '#') to Color
  static Color colorFromHex(String hexCode) {
    return Color(int.parse('0x$hexCode')); // 'FF' is for full opacity
  }
  static Color getDefaultColor() {
    int randomIndex = 0;
    return colorFromHex(colorArray[randomIndex]);
  }

  // Get a random color from the array
  static Color getRandomColor() {
    int randomIndex = (colorArray.length * (new DateTime.now().millisecondsSinceEpoch % 100) / 100).toInt();
    return colorFromHex(colorArray[randomIndex]);
  }
}

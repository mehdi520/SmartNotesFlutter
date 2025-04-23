
import 'package:flutter/material.dart';

class ColorUtils {
  static List<String> colorArray = [
    '#9990FF',  // Light Purple
    '#FF5723',  // Deep Orange
    '#FF4081',  // Pink
    '#4CAF50',  // Green
    '#2196F3',  // Blue
    '#9C27B0',  // Purple
    '#00BCD4',  // Cyan
    '#3F51B5',  // Indigo
    '#8BC34A',  // Light Green
    '#FFEB3B',  // Yellow
    '#009688',  // Teal
    '#673AB7',  // Deep Purple
    '#795548',  // Brown
    '#607D8B',  // Blue Grey
  ];

  // Function to convert hex (without '#') to Color
  static Color colorFromHex(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add opacity if missing
    }
    return Color(int.parse(hex, radix: 16));
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

import 'package:flutter/material.dart';

class FoldedCornerClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);                     // Top-left of the triangle
    path.lineTo(size.width, 0);           // Top-right
    path.lineTo(size.width, size.height); // Bottom-right
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

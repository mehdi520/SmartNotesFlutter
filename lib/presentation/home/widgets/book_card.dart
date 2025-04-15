
import 'package:flutter/material.dart';

import '../../../infra/core/core_exports.dart';
class BookCard extends StatelessWidget {
  const BookCard({
    super.key,
    required this.title,
    required this.fileCount,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String fileCount;
  final String iconColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, AppRoutes.note);
      },
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 320, // 💡 This makes it not stretch too wide on web
            minWidth: 250,
            maxHeight: 300,
            minHeight: 110
          ),
          child: Container(
            padding: EdgeInsets.all(16),
            margin: EdgeInsets.all(8), // optional spacing around the card
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(60),
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(2, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor:
                  Color(int.parse('0x$iconColor')).withAlpha(50),
                  child: Icon(icon, color: Color(int.parse('0x$iconColor'))),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(fileCount, style: TextStyle(color: Colors.black54)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

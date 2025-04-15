

import 'package:flutter/material.dart';

import '../../../core/core_exports.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const BasicAppBar({
    super.key,
  required this.title
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.white),

      title: Center(
        child: Text(title,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500
        ),)
      ),
      actions: [


        SizedBox(
          width: 50,
        )
      ],
    );
  }

  @override
  Size get preferredSize  => const Size.fromHeight(kToolbarHeight);
}

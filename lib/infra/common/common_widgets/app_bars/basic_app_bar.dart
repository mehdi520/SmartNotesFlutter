

import 'package:flutter/material.dart';

import '../../../core/core_exports.dart';

class BasicAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  /// Optional buttons on the right (e.g. PDF download). Icons are shown in white.
  final List<Widget>? actions;
  const BasicAppBar({
    super.key,
  required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.white),
      actionsIconTheme: IconThemeData(color: AppColors.white),

      title: Text(title,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500
        ),),
      actions: (actions == null || actions!.isEmpty)
          ? const [SizedBox(width: 50)]
          : actions,
    );
  }

  @override
  Size get preferredSize  => const Size.fromHeight(kToolbarHeight);
}

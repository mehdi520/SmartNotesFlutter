import 'package:flutter/material.dart';

import '../../../infra/core/core_exports.dart';

class Header extends StatelessWidget {
  const Header({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20,),
            Text(
              "Welcome, Mehdi !",
              style: TextStyle(color: AppColors.primary),
            ),
            SizedBox(height: 4),
            Text(
              "SMART Notes",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.lightBlue,
              ),
            ),
          ],
        ),
        Spacer(),
        SizedBox(width: 12),
        InkWell(
            onTap: (){
              Scaffold.of(context).openDrawer();
            },
            child: Image.asset(AppImages.menu,height: 30,color: AppColors.primary,))
      ],
    );
  }
}
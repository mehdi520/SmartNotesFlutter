import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/infra/core/core_exports.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/presentation/blocs/user_bloc/user_bloc.dart';
import 'package:note_book/presentation/home/widgets/book_card.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';

import 'widgets/home_header.dart';

class NoteDashboardScreen extends StatelessWidget {

  final List<CatModel> bookList = [
    CatModel(title: "Academic", fileCount: 50, iconColor: 'FF9990FF', id: 1),
    CatModel(title: "Work", fileCount: 50, iconColor: 'FFF0B27A', id: 1),
    CatModel(title: "Others", fileCount: 50, iconColor: 'FF9990FF', id: 1),
    CatModel(title: "Personal", fileCount: 50, iconColor: 'ff6B4EFF', id: 1),
    CatModel(title: "test", fileCount: 50, iconColor: 'FFF0B27A', id: 1),
    CatModel(title: "School", fileCount: 50, iconColor: 'ff6B4EFF', id: 1),
    CatModel(title: "Market", fileCount: 50, iconColor: 'FFF0B27A', id: 1),
    // CatModel(title: "", fileCount: "25 Notes", size: "1.57 GB", icon: Icons.person, iconColor: 'FFF0B27A'),
    // CatModel(title: "", fileCount: "5 Notes", size: "1.02 GB", icon: Icons.insert_drive_file, iconColor: 'FFDF8DE1'),
    // CatModel(title: "", fileCount: "15 Notes", size: "56 MBs", icon: Icons.menu_book, iconColor: 'ff6B4EFF'),
    // CatModel(title: "Academic", fileCount: "50 Notes", size: "2.26 GB", icon: Icons.lightbulb, iconColor: 'FF9990FF'),
    // CatModel(title: "Work", fileCount: "25 Notes", size: "1.57 GB", icon: Icons.person, iconColor: 'FFF0B27A'),
    // CatModel(title: "Others", fileCount: "5 Notes", size: "1.02 GB", icon: Icons.insert_drive_file, iconColor: 'FFDF8DE1'),
    // CatModel(title: "Personal", fileCount: "15 Notes", size: "56 MBs", icon: Icons.menu_book, iconColor: 'ff6B4EFF'),
    // CatModel(title: "Academic", fileCount: "50 Notes", size: "2.26 GB", icon: Icons.lightbulb, iconColor: 'FF9990FF'),
    // CatModel(title: "Work", fileCount: "25 Notes", size: "1.57 GB", icon: Icons.person, iconColor: 'FFF0B27A'),
    // CatModel(title: "Others", fileCount: "5 Notes", size: "1.02 GB", icon: Icons.insert_drive_file, iconColor: 'FFDF8DE1'),
    // CatModel(title: "Personal", fileCount: "15 Notes", size: "56 MBs", icon: Icons.menu_book, iconColor: 'ff6B4EFF'),
    // CatModel(title: "Academic", fileCount: "50 Notes", size: "2.26 GB", icon: Icons.lightbulb, iconColor: 'FF9990FF'),
    // CatModel(title: "Work", fileCount: "25 Notes", size: "1.57 GB", icon: Icons.person, iconColor: 'FFF0B27A'),
    // CatModel(title: "Others", fileCount: "5 Notes", size: "1.02 GB", icon: Icons.insert_drive_file, iconColor: 'FFDF8DE1'),
  ];



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: Icon(Icons.add, size: 32),
        onPressed: () {
          Navigator.pushNamed(
              context,  AppRoutes.categoryRoute
          );
        },
      ),
      drawer: _navDrawer(context),
      body: SafeArea(
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: context.mediaQueryWidth * 0.09, vertical: context.mediaQueryHeight * 0.01),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              BlocBuilder<UserBloc, UserState>(
                builder: (context, state) {
                  final user = state.user ?? HiveManager.getUserJson();
                  return Header(userName: user?.name ?? '');
                },
              ),
              const SizedBox(height: 24),

              // Available Space Card
              Banner(),
              const SizedBox(height: 24),

              Expanded(
                child: GridView.builder(
                  itemCount: bookList.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 295,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    final book = bookList[index];
                    return BookCard(
                      title: book.title.toString(),
                      fileCount: book.fileCount.toString() + "Notes",
                      icon: Icons.menu_book,
                      iconColor: book.iconColor.toString(),
                    );
                  },
                ),
              ),


              // // File Category Grid
              // Expanded(
              //   child: GridView.count(
              //     crossAxisCount: 5,
              //     crossAxisSpacing: 16,
              //     mainAxisSpacing: 16,
              //     children: [
              //       BookCard(title: "Personal", fileCount: "15 Notes", size: "56 MBs", icon: Icons.menu_book, iconColor: 'ff6B4EFF',),
              //       BookCard(title: "Academic", fileCount: "50 Notes", size: "2.26 GB", icon: Icons.lightbulb, iconColor: 'FF9990FF'),
              //       BookCard(title: "Work", fileCount: "25 Notes", size: "1.57 GB", icon: Icons.person, iconColor: 'FFF0B27A'),
              //       BookCard(title: "Others", fileCount: "5 Notes", size: "1.02 GB", icon: Icons.insert_drive_file, iconColor: 'FFDF8DE1'),
              //       BookCard(title: "Personal", fileCount: "15 Notes", size: "56 MBs", icon: Icons.menu_book, iconColor: 'ff6B4EFF',),
              //       BookCard(title: "Academic", fileCount: "50 Notes", size: "2.26 GB", icon: Icons.lightbulb, iconColor: 'FF9990FF'),
              //       BookCard(title: "Work", fileCount: "25 Notes", size: "1.57 GB", icon: Icons.person, iconColor: 'FFF0B27A'),
              //       BookCard(title: "Others", fileCount: "5 Notes", size: "1.02 GB", icon: Icons.insert_drive_file, iconColor: 'FFDF8DE1'),
              //     ],
              //   ),
              // )
            ],
          ),
        ),
      ),
    );
  }

  Container Banner() {
    return Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color(0xFF6759F3),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.pie_chart, color: Colors.white, size: 32),
                  ),
                  SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Your Smart Notes",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Everything is neatly organized.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
  }

  Widget _navDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              final user = state.user ?? HiveManager.getUserJson();
              return DrawerHeader(
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                ),
                child: Column(
                  children: [
                    Container(
                      height: 69,
                      width: 70,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(35),
                          color: AppColors.primary),
                      child: Align(
                        alignment: Alignment.center,
                        child: Image.asset(
                          AppImages.profile_icon,
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      user?.name ?? '',
                      style: TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      user?.email ?? '',
                      style: TextStyle(
                          color: AppColors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: Image.asset(
              AppImages.profile_icon,
              height: 25,
              width: 25,
            ),
            title: Text('Profile'),
            onTap: () {
              Navigator.pushNamed(
                  context,  AppRoutes.accRoute
              );

            },
          ),
          ListTile(
            leading: Icon(
              Icons.menu_book,
              size: 25,
            ),
            title: Text('Note Books'),
            onTap: () {
              Navigator.pushNamed(
                  context,  AppRoutes.categoryRoute
              );
            },
          ),
          ListTile(
            leading: Icon(
              Icons.settings,
              size: 25,
            ),
            title: Text('Change Password'),
            onTap: () {
              Navigator.pushNamed(
                  context,  AppRoutes.changepass
              );

            },
          ),
          ListTile(
            leading: Icon(
              Icons.logout,
              size: 25,
            ),
            title: Text('Logout'),
            onTap: () {
              // Clear user data and token
             HiveManager.clearUserData();
              
              // Clear navigation stack and go to login
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.loginRoute,
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

}




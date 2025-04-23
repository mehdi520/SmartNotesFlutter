import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note_book/domain/models/category/data_models/cat_model/cat_model.dart';
import 'package:note_book/infra/core/core_exports.dart';
import 'package:note_book/infra/extensions/media_query_extension.dart';
import 'package:note_book/infra/loader/overlay_service.dart';
import 'package:note_book/infra/utils/enums.dart';
import 'package:note_book/infra/utils/toast_utils.dart';
import 'package:note_book/presentation/blocs/cat_bloc/cat_bloc.dart';
import 'package:note_book/presentation/blocs/user_bloc/user_bloc.dart';
import 'package:note_book/presentation/home/widgets/book_card.dart';
import 'package:note_book/data/data_sources/local/HiveManager.dart';

import 'widgets/home_header.dart';

class NoteDashboardScreen extends StatelessWidget {
  final OverlayService _loadingService = OverlayService();



  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CatBloc()..add(GetCatEvent()),
      child: _NoteDashboardContent(
        loadingService: _loadingService,
      ),
    );
  }
}

class _NoteDashboardContent extends StatelessWidget {
  final OverlayService loadingService;


  const _NoteDashboardContent({
    required this.loadingService,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        child: Icon(Icons.add, size: 32),
        onPressed: () {
          final bloc = context.read<CatBloc>();
          Navigator.pushNamed(
            context,
            AppRoutes.categoryRoute,
            arguments: bloc,
          );
        },
      ),
      drawer: _navDrawer(context),
      body: SafeArea(
        child: BlocListener<CatBloc, CatState>(
          listenWhen: (previous, current) => current.apiIdentifier == "get_cat",
          listener: (context, state) {
            print("home state "  + state.apiStatus.toString());

            if (state.apiStatus == ApiStatus.loading) {
              loadingService.showLoadingOverlay(context);
            }

            if (state.apiStatus == ApiStatus.success) {
              loadingService.hideLoadingOverlay();
            }
            if (state.apiStatus == ApiStatus.error) {
              loadingService.hideLoadingOverlay();
              ToastUtils.showError(state.resp?.message ?? ' failed');
            }
          },
          child: BlocBuilder<CatBloc, CatState>(
            builder: (context, state) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: context.mediaQueryWidth * 0.09,
                    vertical: context.mediaQueryHeight * 0.01),
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
                        itemCount: state.cats!.length,
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 295,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.9,
                        ),
                        itemBuilder: (context, index) {
                          final book = state.cats![index];
                          return BookCard(
                            title: book.title.toString(),
                            fileCount: book.userId.toString() + "Notes",
                            icon: Icons.menu_book,
                            iconColor: book.iconColor.toString(),
                            noteBookId: book.noteBookId, cat: book,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
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
                  context, AppRoutes.accRoute
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
                  context, AppRoutes.categoryRoute
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
                  context, AppRoutes.changepass
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




// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:sorted_storage/layout/layout.dart';
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: AppSpacings.six),
                  Row(
                    children: [
                      SizedBox(width: AppSpacings.twelve),
                      InkWell(
                        customBorder: const CircleBorder(),
                        onTap: createNewFolder,
                        child: Padding(
                          padding: EdgeInsets.all(AppSpacings.twelve),
                          child: const Icon(EvaIcons.folderAdd),
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        key: const Key('home_page_about_button'),
                        customBorder: const StadiumBorder(),
                        onTap: () => context
                            .read<LandingNavigationBloc>()
                            .add(const LandingNavigationAboutButtonPressed()),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacings.four,
                            horizontal: AppSpacings.eight,
                          ),
                          child: Image.asset(
                            'assets/images/logo_tiny.png',
                            height: AppSpacings.fortyEight,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacings.twelve),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void createNewFolder() {
    // TODO: create a new folder with this folder as parent
  }
}

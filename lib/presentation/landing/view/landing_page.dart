// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:sorted_storage/presentation/about/view/about_page.dart';
import 'package:sorted_storage/presentation/home/view/home_page.dart';
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';
import 'package:sorted_storage/presentation/profile/view/profile_page.dart';
import 'package:sorted_storage/themes/colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<LandingNavigationBloc, int>(
        builder: (context, state) {
          switch (state) {
            case 1:
              return const ProfilePage();
            case 2:
              return const AboutPage();
            case 0:
            default:
              return const HomePage();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context
            .read<LandingNavigationBloc>()
            .add(LandingNavigationFloatingActionButtonPressed(context)),
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.sentiment_satisfied,
          color: StorageColors.grey,
        ),
      ),
    );
  }
}

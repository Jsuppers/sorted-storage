// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:sorted_storage/constants/constants.dart';
import 'package:sorted_storage/presentation/about/view/about_page.dart';
import 'package:sorted_storage/presentation/home/view/home_page.dart';
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';
import 'package:sorted_storage/presentation/landing/components/components.dart';
import 'package:sorted_storage/presentation/profile/view/profile_page.dart';
import 'package:sorted_storage/themes/colors.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _overlayEntry = OverlayEntry(
    builder: (context) {
      return const LandingFabExtender();
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<LandingNavigationBloc, LandingNavigationState>(
        listenWhen: (previous, current) =>
            previous != current ||
            current is LandingNavigationFloatingActionButtonToggledInProgress,
        listener: (context, state) {
          if (state is LandingNavigationPageChangeSuccess &&
              _overlayEntry.mounted) {
            _overlayEntry.remove();
          } else if (state
              is LandingNavigationFloatingActionButtonToggledInProgress) {
            if (_overlayEntry.mounted) {
              _overlayEntry.remove();
            } else {
              Overlay.of(context)?.insert(_overlayEntry);
            }
          } else if (state is LandingNavigationOpenDonationPageInProgress) {
            launch(LinkConstants.donationPage);
          }
        },
        buildWhen: (previous, current) =>
            current is LandingNavigationPageChangeSuccess &&
            previous != current,
        builder: (context, state) {
          switch ((state as LandingNavigationPageChangeSuccess).index) {
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
        key: const Key('landing_page_floating_action_button'),
        onPressed: () => context
            .read<LandingNavigationBloc>()
            .add(const LandingNavigationFloatingActionButtonPressed()),
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.sentiment_satisfied,
          color: StorageColors.blueGrey,
        ),
      ),
    );
  }
}

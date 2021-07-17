// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';
import 'package:sorted_storage/presentation/landing/components/landing_fab_extender_button.dart';
import 'package:sorted_storage/themes/colors.dart';

class LandingFabExtender extends StatelessWidget {
  const LandingFabExtender({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      right: 12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LandingFabExtenderButton(
            key: const Key('landing_fab_extender_donate_button'),
            icon: const Icon(Icons.favorite),
            title: 'Donate',
            color: StorageColors.neonRed,
            onTap: () => context
                .read<LandingNavigationBloc>()
                .add(const LandingNavigationDonateButtonPressed()),
          ),
          LandingFabExtenderButton(
            key: const Key('landing_fab_extender_profile_button'),
            icon: const Icon(Icons.person),
            title: 'Profile',
            color: StorageColors.green,
            onTap: () => context
                .read<LandingNavigationBloc>()
                .add(const LandingNavigationProfileButtonPressed()),
          ),
          LandingFabExtenderButton(
            key: const Key('landing_fab_extender_home_button'),
            icon: const Icon(Icons.home),
            title: 'Home',
            color: StorageColors.neonBlue,
            onTap: () => context
                .read<LandingNavigationBloc>()
                .add(const LandingNavigationHomeButtonPressed()),
          ),
        ],
      ),
    );
  }
}

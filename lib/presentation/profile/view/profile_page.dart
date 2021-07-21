// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:sorted_storage/layout/layout.dart';
import 'package:sorted_storage/presentation/landing/bloc/landing_navigation_bloc.dart';
import 'package:sorted_storage/presentation/profile/bloc/profile_bloc.dart';
import 'package:sorted_storage/presentation/profile/components/profile_dialog.dart';
import 'package:sorted_storage/presentation/profile/components/search_bar.dart';
import 'package:sorted_storage/widgets/buttons/circular_back_button.dart';
import 'package:sorted_storage/widgets/dialogs/dialogs.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key, this.profileBloc}) : super(key: key);
  final ProfileBloc? profileBloc;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: profileBloc ?? ProfileBloc(),
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocListener<ProfileBloc, ProfileState>(
        listenWhen: (_, current) => current is ProfileDialogShowedSuccess,
        listener: (context, state) async {
          await showCustomDialog(
            context: context,
            child: BlocProvider.value(
              value: context.read<ProfileBloc>(),
              child: const ProfileDialog(),
            ),
          );
        },
        child: CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  SizedBox(height: AppSpacings.eight),
                  Row(
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacings.eight),
                        child: CircularBackButton(
                          key: const Key('profile_view_back_button'),
                          onTap: () =>
                              context.read<LandingNavigationBloc>().add(
                                    // ignore: lines_longer_than_80_chars
                                    const LandingNavigationProfileBackButtonPressed(),
                                  ),
                        ),
                      ),
                      const Expanded(child: SearchBar()),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: AppSpacings.eight),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: createNewFolder,
                          child: Padding(
                            padding: EdgeInsets.all(AppSpacings.twelve),
                            child: const Icon(EvaIcons.folderAdd),
                          ),
                        ),
                      ),
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      context.read<ProfileBloc>().add(const ProfileDialogShowed());
    });
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:sorted_storage/layout/spacings.dart';
import 'package:sorted_storage/presentation/profile/bloc/profile_bloc.dart';
import 'package:sorted_storage/themes/colors.dart';
import 'package:sorted_storage/utils/services/authentication/authentication.dart';

class ProfileDialog extends StatelessWidget {
  const ProfileDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);
    final _mediaQuery = MediaQuery.of(context);

    return BlocListener<ProfileBloc, ProfileState>(
      listenWhen: (_, current) => current is! ProfileDialogShowed,
      listener: (context, state) {
        if (state is ProfileLogoutSuccess) {
          Navigator.of(context).pop();
          context.read<AuthenticationRepository>().signOut();
        } else if (state is ProfileDialogCloseSuccess) {
          Navigator.of(context).pop();
        }
      },
      child: SizedBox(
        width: _mediaQuery.size.height * 0.8,
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: AppSpacings.twelve,
            horizontal: AppSpacings.sixteen,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.read<AuthenticationRepository>().username,
                        style: _theme.textTheme.headline6,
                      ),
                      Text(
                        context.read<AuthenticationRepository>().email!,
                        style: _theme.textTheme.bodyText2!
                            .copyWith(color: StorageColors.black50),
                      ),
                    ],
                  ),
                  CircleAvatar(
                    child: Image.network(
                      context.read<AuthenticationRepository>().photoUrl,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacings.thirtyTwo),
              // TODO: Replace this with dashboard showing free space,
              // total storage space, etc.
              const Placeholder(
                fallbackHeight: 120,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    key: const Key('profile_dialog_logout_button'),
                    onPressed: () => context
                        .read<ProfileBloc>()
                        .add(const ProfileLogoutButtonPressed()),
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(StorageColors.blueGrey),
                      side: MaterialStateProperty.all(
                        const BorderSide(color: StorageColors.blueGrey),
                      ),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  ),
                  ElevatedButton(
                    key: const Key('profile_dialog_close_button'),
                    onPressed: () => context
                        .read<ProfileBloc>()
                        .add(const ProfileCloseButtonPressed()),
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all(StorageColors.whitePink),
                      backgroundColor:
                          MaterialStateProperty.all(StorageColors.blueGrey),
                    ),
                    child: const Text('close'),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

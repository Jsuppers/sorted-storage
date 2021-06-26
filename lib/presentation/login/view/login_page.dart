// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:sorted_storage/constants/constants.dart';
import 'package:sorted_storage/layout/layout.dart';
import 'package:sorted_storage/presentation/login/components/components.dart';
import 'package:sorted_storage/themes/themes.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Image.asset('assets/images/login_background.png'),
            Padding(
              padding: EdgeInsets.only(top: _size.height * 0.1),
              child: Align(
                alignment: Alignment.topCenter,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: _size.height * 0.3,
                ),
              ),
            ),
            Column(
              children: [
                SizedBox(height: _size.height * 0.4 + AppSpacings.fortyEight),
                Text(
                  'The best place to sort, store, and share your files!',
                  style: StorageTextStyle.subtitle2,
                ),
                SizedBox(height: AppSpacings.fortyEight),
                const GoogleAuthButton(),
                if (kIsWeb)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacings.twelve),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          'assets/images/google-play-badge.png',
                          height: 100,
                        ),
                        Image.asset(
                          'assets/images/app-store-badge.png',
                          height: 70,
                        ),
                      ],
                    ),
                  ),
                const Spacer(),
                Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: AppSpacings.twelve,
                    horizontal: AppSpacings.sixteen,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () async =>
                            await launch(LinkConstants.privacyPolicy),
                        customBorder: const StadiumBorder(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacings.four,
                            horizontal: AppSpacings.eight,
                          ),
                          child: Text(
                            'Privacy Policy',
                            style: StorageTextStyle.caption,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async =>
                            await launch(LinkConstants.termsAndConditions),
                        customBorder: const StadiumBorder(),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacings.four,
                            horizontal: AppSpacings.eight,
                          ),
                          child: Text(
                            'Terms and Conditions',
                            style: StorageTextStyle.caption,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

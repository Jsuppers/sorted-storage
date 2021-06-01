// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import 'package:web/app/blocs/cookie_notice/cookie_notice_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/ui/theme/theme.dart';

/// cookie dialog
class CookieDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: <Widget>[
                Image.asset('assets/images/cookie.png'),
                const Text('This site uses cookies, by continuing to use this '
                    'site we assume you have read and agree with our:'),
                InkWell(
                  onTap: () =>
                      launch('https://sortedstorage.com/#/terms-of-conditions'),
                  child: const Text('Terms of conditions'),
                ),
                InkWell(
                  onTap: () =>
                      launch('https://sortedstorage.com/#/privacy-policy'),
                  child: const Text('privacy policy'),
                ),
                const SizedBox(height: 20),
                MaterialButton(
                  color: myThemeData.primaryColorDark,
                  onPressed: () {
                    BlocProvider.of<CookieNoticeBloc>(context).acceptCookie();
                    BlocProvider.of<NavigationBloc>(context)
                        .add(NavigatorPopEvent());
                  },
                  child: Text('ok', style: myThemeData.textTheme.button),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

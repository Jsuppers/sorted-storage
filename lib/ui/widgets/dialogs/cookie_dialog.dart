import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/app/blocs/cookie_notice/cookie_notice_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/ui/theme/theme.dart';

class CookieDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Image.asset("assets/images/cookie.png"),
                  Text(
                      "This site uses cookies, by continuing to use this site we assume you have read and agree with our:"),
                  InkWell(
                      child: new Text('Terms of conditions'),
                      onTap: () => launch(
                          'https://sortedstorage.com/#/terms-of-conditions')),
                  InkWell(
                      child: new Text('privacy policy'),
                      onTap: () =>
                          launch('https://sortedstorage.com/#/privacy-policy')),
                  SizedBox(height: 20),
                  MaterialButton(
                    color: myThemeData.primaryColorDark,
                    onPressed: () {
                      BlocProvider.of<CookieNoticeBloc>(context).acceptCookie();
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent());
                    },
                    child: Text("ok", style: myThemeData.textTheme.button),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

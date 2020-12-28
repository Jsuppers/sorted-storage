import 'package:flutter/material.dart';

/// Navigation logo which shows a logo without or with text
class NavBarLogo extends StatelessWidget {
  // ignore: public_member_api_docs
  const NavBarLogo({Key key, this.showText}) : super(key: key);

  /// should show logo with text
  final bool showText;


  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: <Widget>[
            Image.asset(showText
                ? 'assets/images/logo.png'
                : 'assets/images/logo_no_text.png'),
          ],
        ),
      ),
    );
  }
}

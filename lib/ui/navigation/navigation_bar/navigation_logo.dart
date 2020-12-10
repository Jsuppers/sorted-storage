import 'package:flutter/material.dart';

class NavBarLogo extends StatelessWidget {
  final bool showText;

  const NavBarLogo({Key key, this.showText}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Container(
          child: Row(
            children: [
              Image.asset(this.showText
                  ? "assets/images/logo.png"
                  : "assets/images/logo_no_text.png"),
            ],
          ),
        ),
      ),
    );
  }
}

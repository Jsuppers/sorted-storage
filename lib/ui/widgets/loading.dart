import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:web/ui/theme/theme.dart';

///
class FullPageLoadingLogo extends StatelessWidget {
  // ignore: public_member_api_docs
  const FullPageLoadingLogo({Key? key, required this.backgroundColor})
      : super(key: key);

  // ignore: public_member_api_docs
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final Decoration decoration = backgroundColor != null
        ? BoxDecoration(color: backgroundColor)
        : myBackgroundDecoration;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: decoration,
        child: StaticLoadingLogo(),
      ),
    );
  }
}

// ignore: public_member_api_docs
class StaticLoadingLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpinKitFadingCircle(color: myThemeData.primaryColorDark);
  }
}

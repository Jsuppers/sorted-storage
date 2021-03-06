// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

/// Navigation logo which shows a logo without or with text
class NavBarLogo extends StatelessWidget {
  // ignore: public_member_api_docs
  const NavBarLogo({Key? key, this.showText = true, this.height = 60})
      : super(key: key);

  /// should show logo with text
  final bool showText;

  final double height;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () =>
            BlocProvider.of<NavigationBloc>(context).add(NavigateToHomeEvent()),
        child: SizedBox(
          height: height,
          child: Image.asset(showText
              ? 'assets/images/logo_tiny.png'
              : 'assets/images/logo_no_text.png'),
        ),
      ),
    );
  }
}

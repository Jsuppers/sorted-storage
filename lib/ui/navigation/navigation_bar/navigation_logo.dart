import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

/// Navigation logo which shows a logo without or with text
class NavBarLogo extends StatelessWidget {
  // ignore: public_member_api_docs
  const NavBarLogo({Key? key, this.showText = true}) : super(key: key);

  /// should show logo with text
  final bool showText;


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        BlocProvider.of<NavigationBloc>(context).add(NavigateToHomeEvent());
      },
      child: SizedBox(
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
      ),
    );
  }
}

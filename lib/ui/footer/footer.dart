// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

/// The footer which contains the privacy policy and terms of conditions
class Footer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            MaterialButton(
              onPressed: () => BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToPrivacyEvent()),
              child: Text('Privacy Policy',
                  style: Theme.of(context).textTheme.bodyText1),
            ),
            const Text(' - '),
            MaterialButton(
              onPressed: () => BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToTermsEvent()),
              child: Text('Terms of Conditions',
                  style: Theme.of(context).textTheme.bodyText1),
            )
          ],
        ),
      ),
    );
  }
}

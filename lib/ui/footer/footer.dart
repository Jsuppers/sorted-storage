import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

/// The footer which contains the privacy policy and terms of conditions
class Footer extends StatelessWidget {
  /// constructor which sets the width
  const Footer(this._width, {Key key}) : super(key: key);

  final double _width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: SizedBox(
        width: _width,
        child: Center(
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
      ),
    );
  }
}

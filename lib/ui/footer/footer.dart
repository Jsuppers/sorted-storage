import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

class Footer extends StatelessWidget {
  final double width;

  const Footer({Key key, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Container(
        width: width,
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              MaterialButton(
                onPressed: () => BlocProvider.of<NavigationBloc>(context)
                    .add(NavigateToPrivacyEvent()),
                child: Text('Privacy Policy',
                    style: Theme.of(context).textTheme.bodyText1),
              ),
              Text(" - "),
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

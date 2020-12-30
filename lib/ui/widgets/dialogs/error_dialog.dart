import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/ui/theme/theme.dart';

/// dialog to show errors
class ErrorDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const ErrorDialog({Key key, this.errorMessages}) : super(key: key);

  // ignore: public_member_api_docs
  final List<String> errorMessages;

  @override
  Widget build(BuildContext context) {
    return Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        elevation: 1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 20),
                Image.asset('assets/images/error.png', height: 80),
                Text('Oh no! something went wrong!',
                    style: myThemeData.textTheme.headline3),
                Text('we could not:', style: myThemeData.textTheme.bodyText1),
              ],
            ),
            ResponsiveBuilder(
                builder: (BuildContext context, SizingInformation info) {
              return SizedBox(
                  height: info.screenSize.height - 300.0,
                  child: ListView.builder(
                    itemCount: errorMessages.length,
                    itemBuilder: (BuildContext context, int index) {
                      return ListTile(
                        title: Text(
                          errorMessages[index],
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ));
            }),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  MaterialButton(
                      minWidth: 100,
                      color: myThemeData.primaryColorDark,
                      textColor: myThemeData.primaryColor,
                      onPressed: () => BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent()),
                      child: Row(
                        children: const <Widget>[
                          Text('close'),
                        ],
                      )),
                ],
              ),
            ),
          ],
        ));
  }
}

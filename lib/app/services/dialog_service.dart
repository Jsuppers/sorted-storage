
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/app/blocs/cookie/cookie_bloc.dart';
import 'package:web/app/blocs/cookie/cookie_event.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/blocs/sharing/sharing_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';

class DialogStreamContent {
  final String text;
  final int value;

  DialogStreamContent(this.text, this.value);
}

class ShareWidget extends StatefulWidget {
  final String folderID;
  final bool shared;

  const ShareWidget({Key key, this.folderID, this.shared}) : super(key: key);

  @override
  _ShareWidgetState createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  @override
  Widget build(BuildContext context) {
    bool shared = widget.shared;
    print('rebuilding $shared');
    TextEditingController controller = new TextEditingController();

    if (shared) {
      controller.text = "${Constants.WEBSITE_URL}/view/${widget.folderID}";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        shared
            ? Container(
                padding: EdgeInsets.all(20),
                width: 300,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.copy, size: 20),
                      iconSize: 20,
                      splashRadius: 20,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: controller.text));
                      },
                    ),
                    SizedBox(width: 10),
                    Container(
                        width: 200,
                        child: new TextField(
                            controller: controller,
                            style: myThemeData.textTheme.bodyText1,
                            minLines: 2,
                            maxLines: 4,
                            readOnly: true))
                  ],
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                    "To make this event publicly visible click the share button."),
              ),
        MaterialButton(
          minWidth: 100,
          onPressed: () async {
            if (shared) {
              BlocProvider.of<SharingBloc>(context).add(StopSharingEvent());
            } else {
              BlocProvider.of<SharingBloc>(context).add(StartSharingEvent());
            }
          },
          child: Text(
            shared ? "stop sharing" : "share",
            style: myThemeData.textTheme.button,
          ),
          color: myThemeData.primaryColorDark,
          textColor: Colors.white,
        ),
        Container(
          padding: EdgeInsets.all(20),
          child: shared
              ? Text(
                  "Everyone with this link can see your content. Be careful who you give it to!")
              : Container(),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MaterialButton(
                    minWidth: 100,
                    child: Row(
                      children: [
                        Icon(
                          Icons.cancel,
                          color: Colors.black,
                        ),
                        SizedBox(width: 5),
                        Text("close"),
                      ],
                    ),
                    color: Colors.white,
                    textColor: Colors.black,
                    onPressed: () {
                      BlocProvider.of<NavigationBloc>(context)
                          .add(NavigatorPopEvent());
                    }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class DialogService {
  static cookieDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        useRootNavigator: true,
        builder: (BuildContext context) {
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
                            onTap: () => launch(
                                'https://sortedstorage.com/#/privacy-policy')),
                        SizedBox(height: 20),
                        MaterialButton(
                          color: myThemeData.primaryColorDark,
                          onPressed: () {
                            BlocProvider.of<CookieBloc>(context)
                                .add(CookieAcceptEvent());
                            BlocProvider.of<NavigationBloc>(context)
                                .add(NavigatorPopEvent());
                          },
                          child:
                              Text("ok", style: myThemeData.textTheme.button),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  static shareDialog(BuildContext context, String folderID, String commentsID) {
    showDialog(
        context: context,
        barrierDismissible: true,
        useRootNavigator: true,
        builder: (BuildContext context) {
          return BlocProvider(
              create: (BuildContext context) => SharingBloc(
                  BlocProvider.of<DriveBloc>(context).state,
                  folderID,
                  commentsID),
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(4.0))),
                elevation: 1,
                child:
                    BlocBuilder<SharingBloc, bool>(builder: (context, shared) {
                      print(shared);
                  if (shared == null) {
                    return FullPageLoadingLogo(backgroundColor: Colors.white);
                  }
                  return ShareWidget(folderID: folderID, shared: shared);
                }),
              ));
        });
  }
}

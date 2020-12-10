import 'package:emojis/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/blocs/sharing/sharing_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/app/blocs/timeline/timeline_bloc.dart';
import 'package:web/app/blocs/timeline/timeline_event.dart';
import 'package:web/app/blocs/timeline/timeline_state.dart';
import 'package:web/app/services/cookie_service.dart';
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
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    bool shared = widget.shared;
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
        ShareButton(
            key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
            shared: shared,
            loading: false),
        Container(
          padding: EdgeInsets.all(20),
          child: shared
              ? Text(
                  "Everyone with this link can see and comment on your content. Be careful who you give it to!")
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

class ShareButton extends StatefulWidget {
  final bool shared;
  final bool loading;

  const ShareButton({Key key, this.shared, this.loading}) : super(key: key);

  @override
  _ShareButtonState createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  bool loading;

  @override
  void initState() {
    super.initState();
    loading = widget.loading;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? StaticLoadingLogo()
        : MaterialButton(
            minWidth: 100,
            onPressed: () async {
              setState(() {
                loading = true;
              });
              if (widget.shared) {
                BlocProvider.of<SharingBloc>(context).add(StopSharingEvent());
              } else {
                BlocProvider.of<SharingBloc>(context).add(StartSharingEvent());
              }
            },
            child: Text(
              widget.shared ? "stop sharing" : "share",
              style: myThemeData.textTheme.button,
            ),
            color: myThemeData.primaryColorDark,
            textColor: Colors.white,
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
                            CookieService.acceptCookie();
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
                  if (shared == null) {
                    return FullPageLoadingLogo(backgroundColor: Colors.white);
                  }
                  return ShareWidget(folderID: folderID, shared: shared);
                }),
              ));
        });
  }

  static pickEmoji(BuildContext context, {String folderID, String parentID}) {
    showDialog(
      context: context,
      barrierDismissible: true,
      useRootNavigator: true,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          elevation: 1,
          child: Container(
            height: 800,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ResponsiveBuilder(
                builder: (context, constraints) {
                  return EmojiPicker(folderID: folderID, parentID: parentID);
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

class EmojiPicker extends StatefulWidget {
  final String folderID;
  final String parentID;

  const EmojiPicker({Key key, this.folderID, this.parentID}) : super(key: key);

  @override
  State createState() => EmojiPickerState();
}

class EmojiPickerState extends State<EmojiPicker> {
  TextEditingController controller = new TextEditingController();
  List<String> possibleMatches = List();
  String filter;
  List<Emoji> flags;

  @override
  void initState() {
    flags = Emoji.byGroup(EmojiGroup.flags).toList();

    Emoji.byGroup(EmojiGroup.travelPlaces).forEach((element) {
      possibleMatches.add(element.char);
    });
    super.initState();

    controller.addListener(() {
      if (controller.text == "") {
        return;
      }

      possibleMatches = List();
      filter = controller.text;
      setState(() {
        flags.forEach((element) {
          if (element.name.contains(filter)) {
            possibleMatches.add(element.char);
          }
        });

        Iterable<Emoji> emojis = Emoji.byKeyword(filter);
        if (emojis != null) {
          emojis.forEach((element) {
            possibleMatches.add(element.char);
          });
        }
        Emoji emoji = Emoji.byName(filter);
        if (emoji != null) {
          possibleMatches.insert(0, emoji.char);
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.transparent,
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Padding(
                padding: new EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
                child: new TextField(
                  style: new TextStyle(fontSize: 18.0, color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: new Icon(Icons.search),
                    suffixIcon: new IconButton(
                      icon: new Icon(Icons.close),
                      onPressed: () {
                        BlocProvider.of<NavigationBloc>(context)
                            .add(NavigatorPopEvent());
                      },
                    ),
                    hintText: "Search...",
                  ),
                  controller: controller,
                )),
            Expanded(
              child: SingleChildScrollView(
                child: new Padding(
                    padding: new EdgeInsets.only(top: 8.0),
                    child: _buildListView()),
              ),
            )
          ],
        ));
  }

  Widget _buildListView() {
    List<Widget> children = List();
    possibleMatches.forEach((element) {
      children.add(
        MaterialButton(
          height: 40,
          onPressed: () {
            BlocProvider.of<TimelineBloc>(context).add(TimelineEvent(
                TimelineMessageType.edit_emoji,
                parentId: widget.parentID,
                folderId: widget.folderID,
                text: element));
            BlocProvider.of<NavigationBloc>(context).add(NavigatorPopEvent());
          },
          child: Text(
            element,
            style: TextStyle(
              fontSize: 24,
              height: 1.1,
            ),
          ),
        ),
      );
    });

    return Align(
      alignment: Alignment.topCenter,
      child: Wrap(
        spacing: 15.0,
        runSpacing: 15.0,
        children: children,
      ),
    );
  }
}

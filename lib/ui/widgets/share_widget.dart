
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/blocs/sharing/sharing_state.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/share_button.dart';

class ShareWidget extends StatefulWidget {
  final String folderID;
  final SharingState state;

  const ShareWidget({Key key, this.folderID, this.state}) : super(key: key);

  @override
  _ShareWidgetState createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    TextEditingController controller = new TextEditingController();
    bool shared = (widget.state is SharingSharedState);
    if (shared) {
      controller.text = "${Constants.WEBSITE_URL}/view/${widget.folderID}";
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        widget.state.errorMessage != null ? Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error),
            SizedBox(width: 5),
            Text(widget.state.errorMessage),
          ],
        ): Container(),
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
                onPressed: () => Clipboard.setData(
                    ClipboardData(text: controller.text)),
              ),
              SizedBox(width: 10),
              Container(
                width: 200,
                child: new TextField(
                    controller: controller,
                    style: myThemeData.textTheme.bodyText1,
                    minLines: 2,
                    maxLines: 4,
                    readOnly: true),
              )
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
                    onPressed: () => BlocProvider.of<NavigationBloc>(context)
                        .add(NavigatorPopEvent())),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

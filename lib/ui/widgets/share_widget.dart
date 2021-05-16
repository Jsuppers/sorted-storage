// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:web/app/blocs/sharing/sharing_state.dart';
import 'package:web/constants.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/share_button.dart';

// ignore: public_member_api_docs
class ShareWidget extends StatefulWidget {
  // ignore: public_member_api_docs
  const ShareWidget({Key? key, required this.folderID, required this.state})
      : super(key: key);

  // ignore: public_member_api_docs
  final String folderID;

  // ignore: public_member_api_docs
  final SharingState state;

  @override
  _ShareWidgetState createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final bool shared = widget.state is SharingSharedState;
    if (shared) {
      controller.text = '${Constants.websiteURL}/${widget.folderID}';
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: CustomScrollView(slivers: <Widget>[
        const SliverAppBar(
          // toolbarHeight: 50,
          floating: true,
          backgroundColor: Colors.white,
          pinned: true,
          elevation: 0.0,
        ),
        SliverToBoxAdapter(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              if (widget.state.errorMessage != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Icon(Icons.error),
                    const SizedBox(width: 5),
                    Text(widget.state.errorMessage!),
                  ],
                )
              else
                Container(),
              if (shared)
                Container(
                  padding: const EdgeInsets.all(20),
                  width: 300,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20),
                        iconSize: 20,
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        onPressed: () => Clipboard.setData(
                            ClipboardData(text: controller.text)),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 200,
                        child: TextField(
                            controller: controller,
                            style: myThemeData.textTheme.bodyText1,
                            minLines: 2,
                            maxLines: 4,
                            readOnly: true),
                      )
                    ],
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text('To make this event publicly visible '
                      'click the share button.'),
                ),
              ShareButton(
                  key: Key(DateTime.now().millisecondsSinceEpoch.toString()),
                  shared: shared),
              Container(
                padding: const EdgeInsets.all(20),
                child: shared
                    ? const Text('Everyone with this link can see and comment '
                        'on your content. '
                        'Be careful who you give it to!')
                    : Container(),
              ),
            ],
          ),
        )
      ]),
    );
  }
}

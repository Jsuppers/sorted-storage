import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/timeline.dart';

/// Page which contains all the stories
class MediaPage extends StatefulWidget {
  MediaPage(this.folderID);

  String folderID;

  @override
  _MediaPageState createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
        CloudStoriesType.retrieveStories,
        folderID: widget.folderID));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Row(
          children: [
            Container(
              height: 50,
              width: constraints.maxWidth,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ButtonWithIcon(
                        text: 'Add',
                        icon: Icons.create_new_folder_outlined,
                        onPressed: () =>
                          DialogService.editDialog(context, parentID: widget.folderID)
                        ,
                        width: constraints.maxWidth,
                        backgroundColor: Colors.transparent,
                        textColor: Colors.black,
                        iconColor: Colors.black),
                    const NavBarLogo(height: 30),
                  ],
                ),
              ),
            ),
            TimelineLayout(
                width: constraints.maxWidth, height: constraints.maxHeight),
          ],
        );
      },
    );
  }
}

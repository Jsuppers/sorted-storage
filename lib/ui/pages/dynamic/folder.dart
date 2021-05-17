// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/models/folder_content.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/timeline.dart';

/// Page which contains all the stories
class FolderPage extends StatefulWidget {
  FolderPage(this.folderID);

  String? folderID;

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  FolderContent? folder;
  bool error = false;

  @override
  void initState() {
    super.initState();
    if (widget.folderID != null && widget.folderID!.isNotEmpty) {
      BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
          CloudStoriesType.retrieveFolder,
          folderID: widget.folderID));
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
        listeners: <BlocListener<dynamic, dynamic>>[
          BlocListener<CloudStoriesBloc, CloudStoriesState?>(
              listener: (BuildContext context, CloudStoriesState? state) {
            if (state == null) {
              return;
            }
            if (state.type == CloudStoriesType.refresh &&
                state.folderID == widget.folderID) {
              setState(() {});
            }
            if (state.type == CloudStoriesType.retrieveFolder &&
                state.folderID == widget.folderID) {
              setState(() {
                folder = state.data as FolderContent;
              });
            }
          }),
        ],
        child: folder == null
            ? StaticLoadingLogo()
            : ResponsiveBuilder(
                builder: (BuildContext context, SizingInformation constraints) {
                  return Column(
                    key: Key(DateTime.now().toString()),
                    children: [
                      Container(
                        height: 50,
                        width: constraints.screenSize.width,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ButtonWithIcon(
                                  text: 'Add',
                                  icon: Icons.create_new_folder_outlined,
                                  onPressed: () => DialogService.editDialog(
                                      context,
                                      parent: folder),
                                  width: constraints.screenSize.width,
                                  backgroundColor: Colors.transparent,
                                  textColor: Colors.black,
                                  iconColor: Colors.black),
                              const NavBarLogo(height: 30),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TimelineLayout(
                            folder: folder!,
                            width: constraints.screenSize.width,
                            height: constraints.screenSize.height),
                      ),
                    ],
                  );
                },
              ));
  }
}

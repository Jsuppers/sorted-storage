// Flutter imports:
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder_content.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/pop_up_options.dart';

class FolderPage extends StatefulWidget {
  FolderPage(this.rootID, {this.editing});

  String rootID;
  bool? editing;

  @override
  _FolderPageState createState() => _FolderPageState();
}

class _FolderPageState extends State<FolderPage> {
  @override
  void initState() {
    super.initState();
    if (widget.rootID.isEmpty) {
      BlocProvider.of<CloudStoriesBloc>(context)
          .add(const CloudStoriesEvent(CloudStoriesType.rootFolder));
    } else {
      BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
          CloudStoriesType.retrieveFolder,
          folderID: widget.rootID));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(alignment: Alignment.topLeft, child: FolderView(folderID: widget.rootID)),
    );
  }
}

class FolderView extends StatefulWidget {
  FolderView({required this.folderID});

  String folderID;
  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  FolderContent? folder;
  String? folderID;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    folderID = widget.folderID;
  }

  String _shortenText(String text) {
    if (text.length <= 20) {
      return text;
    }
    return '${text.substring(0, 17)}...';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if (folder != null &&  folder!.subFolders != null) {
      for (FolderContent subFolder in folder!.subFolders!) {
        children.add(Container(
          height: 40.0,
          width: 220.0,
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(6)),
              color: Colors.white,
              boxShadow: [
                const BoxShadow(color: Colors.black12, blurRadius: 1),
              ],
              border: Border.all(color: myThemeData.dividerColor, width: 1)),
          child: GestureDetector(
            onTap: () => {
              BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToMediaEvent(folderId: subFolder.id!))
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                      width: 30, child: Center(child: Text(subFolder.emoji))),
                ),
                Text(_shortenText(subFolder.title)),
                PopUpOptions(folder: subFolder, parent: folder),
              ],
            ),
          ),
        ));
      }
    }

    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
        listener: (BuildContext context, CloudStoriesState state) {
      if (state.type == CloudStoriesType.rootFolder) {
        final FolderContent folderContent = state.data as FolderContent;
        folderID = folderContent.id;
        BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
            CloudStoriesType.retrieveFolder,
            folderID: folderContent.id));
      }
      if (state.type == CloudStoriesType.retrieveFolder
          && state.folderID == folderID) {
        setState(() {
          folder = state.data as FolderContent;
        });
      }
      if (state.type == CloudStoriesType.refresh &&
          state.folderID == folderID) {
        inspect(folder);
        debugger();
        setState(() {});
//        BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
//            CloudStoriesType.retrieveFolder,
//            folderID: folderID.id));
      }
    }, child: ResponsiveBuilder(
            builder: (BuildContext context, SizingInformation constraints) {
      return Column(
        key: Key(DateTime.now().toString()),
        children: [
          ReorderableWrap(
              header: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ButtonWithIcon(
                          text: 'New Folder',
                          icon: Icons.create_new_folder_outlined,
                          onPressed: () async {
                            if (folder == null) {
                              return;
                            }
                            DialogService.editDialog(context,
                                parent: folder,
                            );
                          },
                          width: constraints.screenSize.width,
                          backgroundColor: Colors.transparent,
                          textColor: Colors.black,
                          iconColor: Colors.black),
                      const NavBarLogo(height: 30),
                    ],
                  ),
                ),
              ],
              spacing: 8.0,
              runSpacing: 4.0,
              padding: const EdgeInsets.all(8),
              onReorder: (int oldIndex, int newIndex) {
                UpdatePosition ui = UpdatePosition(
                  folderID: folderID!,
                    currentIndex: oldIndex,
                    targetIndex: newIndex,
                    metadata: folder?.metadata ?? {},
                    items: <FolderContent>[...folder!.subFolders!]);

                BlocProvider.of<CloudStoriesBloc>(context).add(
                    CloudStoriesEvent(CloudStoriesType.updateFolderPosition,
                        data: ui));

                setState(() {
                  final FolderContent image = folder!.subFolders!.removeAt(oldIndex);
                  folder!.subFolders!.insert(newIndex, image);
                });
              },
              children: children),
          if (folder == null)
            const FullPageLoadingLogo(backgroundColor: Colors.transparent),
          if (folder != null && folder!.subFolders!.isEmpty)
            SizedBox(
              height: constraints.screenSize.height / 1.5,
              child: Center(
                child: SizedBox(
                  height: 300,
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/no_folders.png',
                        height: 150,
                      ),
                      const SizedBox(height: 10),
                      const Text('It looks pretty sad here!'),
                      const SizedBox(height: 10),
                      const Text(
                          "Click 'New Folder' and create something special."),
                    ],
                  ),
                ),
              ),
            )
        ],
      );
    }));
  }
}

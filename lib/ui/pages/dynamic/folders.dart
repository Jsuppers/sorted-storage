// Flutter imports:
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
import 'package:web/app/models/folder_properties.dart';
import 'package:web/app/models/update_index.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/pop_up_options.dart';

class FolderPage extends StatefulWidget {
  FolderPage(this.rootID);

  String rootID;

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
          CloudStoriesType.retrieveFolders,
          folderID: widget.rootID));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(alignment: Alignment.topLeft, child: FolderView()),
    );
  }
}

class FolderView extends StatefulWidget {
  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  List<FolderProperties>? folders;

  String _shortenText(String text) {
    if (text.length <= 20) {
      return text;
    }
    return '${text.substring(0, 17)}...';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if (folders != null) {
      for (FolderProperties folder in folders!) {
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
                  .add(NavigateToMediaEvent(folderId: folder.id!))
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                      width: 30, child: Center(child: Text(folder.emoji))),
                ),
                Text(_shortenText(folder.title)),
                PopUpOptions(folderID: folder.id!, folder: folder),
              ],
            ),
          ),
        ));
      }
    }

    return BlocListener<CloudStoriesBloc, CloudStoriesState>(
        listener: (BuildContext context, CloudStoriesState state) {
      if (state.type == CloudStoriesType.rootFolder) {
        BlocProvider.of<CloudStoriesBloc>(context).add(CloudStoriesEvent(
            CloudStoriesType.retrieveFolders,
            folderID: state.data as String));
      }
      if (state.type == CloudStoriesType.retrieveFolders) {
        setState(() {
          folders = state.data as List<FolderProperties>;
          folders!.sort((a, b) => a.order!.compareTo(b.order!));
        });
      }
    }, child: ResponsiveBuilder(
            builder: (BuildContext context, SizingInformation constraints) {
      return Column(
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
                            if (folders == null) {
                              return;
                            }
                            DialogService.editFolderDialog(context);
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
                UpdateIndex ui =
                    UpdateIndex(oldIndex: oldIndex, newIndex: newIndex);
                BlocProvider.of<CloudStoriesBloc>(context).add(
                    CloudStoriesEvent(CloudStoriesType.updateFolderPosition,
                        data: ui));
                setState(() {
                  final FolderProperties image = folders!.removeAt(oldIndex);
                  folders!.insert(newIndex, image);
                });
              },
              children: children),
          if (folders == null)
            const FullPageLoadingLogo(backgroundColor: Colors.transparent),
          if (folders != null && folders!.isEmpty)
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

  void updateAllFolders(BuildContext context, int oldIndex, int newIndex) {
    final FolderProperties image = folders!.removeAt(oldIndex);
    folders!.insert(newIndex, image);

    for (int i = 0; i < folders!.length; i++) {
      folders![i].order = i.toDouble();
    }
    BlocProvider.of<CloudStoriesBloc>(context)
        .add(CloudStoriesEvent(CloudStoriesType.updateAllFolders));
  }
}

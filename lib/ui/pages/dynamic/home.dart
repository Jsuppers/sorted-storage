// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/extensions/string.dart';

// Project imports:
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_bloc.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_state.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/icon_button.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/pop_up_options.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    BlocProvider.of<FolderStorageBloc>(context)
        .add(const FolderStorageEvent(FolderStorageType.getRootFolder));
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
  Folder? folder;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    if (folder != null) {
      for (final Folder subFolder in folder!.subFolders) {
        children.add(
          GestureDetector(
            onTap: () => {
              BlocProvider.of<NavigationBloc>(context)
                  .add(NavigateToMediaEvent(folderId: subFolder.id!))
            },
            child: Container(
              height: 40.0,
              width: 220.0,
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                  color: Colors.white,
                  boxShadow: [
                    const BoxShadow(color: Colors.black12, blurRadius: 1),
                  ],
                  border:
                      Border.all(color: myThemeData.dividerColor, width: 1)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: SizedBox(
                        width: 30, child: Center(child: Text(subFolder.emoji))),
                  ),
                  Text(subFolder.title.ellipseOverflow(20), maxLines: 1),
                  PopUpOptions(folder: subFolder),
                ],
              ),
            ),
          ),
        );
      }
    }

    return BlocListener<FolderStorageBloc, FolderStorageState?>(
        listener: (BuildContext context, FolderStorageState? state) {
      if (state == null) {
        return;
      }
      if (state.type == FolderStorageType.getRootFolder) {
        setState(() {
          folder = state.data as Folder;
        });
      }
      if (state.type == FolderStorageType.refresh &&
          state.folderID == folder?.id) {
        setState(() {});
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
                            if (folder == null) {
                              return;
                            }
                            DialogService.editDialog(
                              context,
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
                    folder: folder,
                    currentIndex: oldIndex,
                    targetIndex: newIndex,
                    items: <Folder>[...folder!.subFolders]);

                BlocProvider.of<EditorBloc>(context)
                    .add(EditorEvent(EditorType.updatePosition, data: ui));

                setState(() {
                  final Folder image = folder!.subFolders.removeAt(oldIndex);
                  folder!.subFolders.insert(newIndex, image);
                });
              },
              children: children),
          if (folder == null)
            const FullPageLoadingLogo(backgroundColor: Colors.transparent),
          if (folder != null && folder!.subFolders.isEmpty)
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

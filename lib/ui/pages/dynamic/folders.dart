import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder_properties.dart';
import 'package:web/app/models/update_index.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/navigation/navigation_bar/navigation_logo.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/icon_button.dart';
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
      child: Container(
          alignment: Alignment.topLeft,
          child: Column(
            children: [
              NavBarLogo(),
              FolderView(),
            ],
          )),
    );
  }
}

class FolderView extends StatefulWidget {
  @override
  _FolderViewState createState() => _FolderViewState();
}

class _FolderViewState extends State<FolderView> {
  List<FolderProperties> folders = [];

  String _shortenText(String text) {
    if (text.length <= 20) {
      return text;
    }
    return '${text.substring(0, 17)}...';
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];
    for (FolderProperties folder in folders) {
      children.add(Container(
        height: 40.0,
        width: 220.0,
        decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(6)),
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 1),
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
              SizedBox(width: 30, child: Center(child: Text(folder.emoji))),
              Text(_shortenText(folder.title)),
              PopUpOptions(folderID: folder.id!, folder: folder),
            ],
          ),
        ),
      ));
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
          folders.sort((a, b) => a.order!.compareTo(b.order!));
        });
      }
    }, child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
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
                          DialogService.editFolderDialog(context);
                        },
                        width: constraints.maxWidth,
                        backgroundColor: Colors.transparent,
                        textColor: Colors.black,
                        iconColor: Colors.black),

                  ],
                ),
              ),],

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
                  final FolderProperties image = folders.removeAt(oldIndex);
                  folders.insert(newIndex, image);
                });
              },
              children: children),
        ],
      );
    }));
  }

  void updateAllFolders(BuildContext context, int oldIndex, int newIndex) {
    final FolderProperties image = folders.removeAt(oldIndex);
    folders.insert(newIndex, image);

    for (int i = 0; i < folders.length; i++) {
      folders[i].order = i.toDouble();
    }
    BlocProvider.of<CloudStoriesBloc>(context)
        .add(CloudStoriesEvent(CloudStoriesType.updateAllFolders));
  }
}

// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/folder_storage/folder_storage_bloc.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_state.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/file_data.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/folder_image.dart';
import 'package:web/ui/widgets/pop_up_options.dart';

// ignore: public_member_api_docs
class BasicLayout extends StatefulWidget {
  // ignore: public_member_api_docs
  const BasicLayout({
    Key? key,
    required this.width,
    required this.height,
    required this.folder,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final double width;

  // ignore: public_member_api_docs
  final double height;

  final Folder folder;

  @override
  State<StatefulWidget> createState() => _BasicLayoutState();
}

class _BasicLayoutState extends State<BasicLayout> {
  late Folder currentFolder;

  @override
  void initState() {
    super.initState();
    currentFolder = widget.folder;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> subFolders = <Widget>[];

    Folder.sortFoldersByOrder(currentFolder.subFolders);
    for (final Folder subFolder in currentFolder.subFolders) {
      subFolders.add(
        GestureDetector(
          onTap: () {
            if (subFolder.loaded == false) {
              BlocProvider.of<FolderStorageBloc>(context).add(
                  FolderStorageEvent(FolderStorageType.getFolder,
                      data: subFolder, folderID: subFolder.id));
            }
            setState(() => currentFolder = subFolder);
          },
          child: Container(
            height: 70.0,
            width: 70.0,
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                color: Colors.white,
                boxShadow: [
                  const BoxShadow(color: Colors.black12, blurRadius: 1),
                ],
                border: Border.all(color: myThemeData.dividerColor, width: 1)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: SizedBox(
                      height: 30,
                      width: 30,
                      child: Center(
                          child: Text(subFolder.emoji,
                              style: const TextStyle(
                                fontSize: 20.0,
                              )))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Text(subFolder.title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      softWrap: false,
                      style: myThemeData.textTheme.bodyText1),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final List<Widget> nonRootContent = <Widget>[];
    if (currentFolder != widget.folder) {
      final List<FolderImage> cards = <FolderImage>[];
      for (final MapEntry<String, FileData> image
          in currentFolder.files.entries) {
        cards.add(FolderImage(
          locked: true,
          folderMedia: image.value,
          imageKey: image.key,
          folder: currentFolder,
        ));
      }

      cards.sort((FolderImage a, FolderImage b) {
        final double first = a.folderMedia.metadata.getOrder() ?? 0;
        final double second = b.folderMedia.metadata.getOrder() ?? 0;
        return first.compareTo(second);
      });
      nonRootContent.addAll([
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(currentFolder.title, style: myThemeData.textTheme.headline3),
            PopUpOptions(
              folder: currentFolder,
            ),
          ],
        ),
        Text(currentFolder.metadata.getDescription(),
            style: myThemeData.textTheme.bodyText1),
        Text('Files', style: myThemeData.textTheme.headline4),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Wrap(spacing: 8.0, runSpacing: 4.0, children: cards)),
      ]);
    }

    return BlocListener<FolderStorageBloc, FolderStorageState?>(
      listener: (BuildContext context, FolderStorageState? state) {
        if (state == null) {
          return;
        }
        if (state.type == FolderStorageType.refresh &&
            state.folderID == currentFolder.parent?.id) {
          setState(() {});
        }
        if (state.type == FolderStorageType.getFolder &&
            state.folderID == currentFolder.id) {
          setState(() {
            currentFolder = state.data as Folder;
          });
        }
      },
      child: SizedBox(
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...nonRootContent,
            Text('Folders', style: myThemeData.textTheme.headline4),
            SizedBox(height: 15),
            Wrap(spacing: 8.0, runSpacing: 4.0, children: subFolders),
          ],
        ),
      ),
    );
  }
}

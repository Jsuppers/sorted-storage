// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:web/app/models/folder.dart';
import 'package:web/ui/theme/theme.dart';

class FoldersList extends StatefulWidget {
  FoldersList({required this.subFolders, this.subFolderClick});

  List<Folder> subFolders;
  Function(Folder)? subFolderClick;
  @override
  _FoldersListState createState() => _FoldersListState();
}

class _FoldersListState extends State<FoldersList> {
  @override
  Widget build(BuildContext context) {
    if (widget.subFolders.isEmpty) {
      return Container();
    }

    final List<Widget> subFolders = <Widget>[];

    Folder.sortFoldersByOrder(widget.subFolders);
    for (final Folder subFolder in widget.subFolders) {
      subFolders.add(
        GestureDetector(
          onTap: () {
            if (widget.subFolderClick != null) {
              widget.subFolderClick!(subFolder);
            }
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

    return Wrap(spacing: 8.0, runSpacing: 4.0, children: subFolders);
  }
}

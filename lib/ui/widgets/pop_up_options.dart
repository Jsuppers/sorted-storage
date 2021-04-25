import 'package:flutter/material.dart';
import 'package:web/app/models/folder_properties.dart';
import 'package:web/app/services/dialog_service.dart';

class PopUpOptions extends StatelessWidget {
  PopUpOptions({required this.folderID, this.subFolderID, this.folder});

  String folderID;
  FolderProperties? folder;
  String? subFolderID;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: EdgeInsets.zero,
      alignment: Alignment.centerRight,
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          switch (value) {
            case 'Edit':
              if (folder != null) {
                DialogService.editFolderDialog(context, folder: folder);
              } else {
                DialogService.editDialog(context, folderID: folderID);
              }
              break;
            case 'Share':
              DialogService.shareDialog(
                  context, subFolderID ?? folderID);
              break;
            default:
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return {'Edit', 'Share', 'Cancel'}.map((String choice) {
            return PopupMenuItem<String>(
              value: choice,
              child: Text(choice),
            );
          }).toList();
        },
      ),
    );
  }
}

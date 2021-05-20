// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:web/app/models/folder_content.dart';
import 'package:web/app/services/dialog_service.dart';

class PopUpOptions extends StatelessWidget {
  PopUpOptions({this.folder});

  FolderContent? folder;

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
              DialogService.editDialog(context,
                  folder: folder, parent: folder?.parent);
              break;
          }
        },
        itemBuilder: (BuildContext context) {
          return {'Edit', 'Cancel'}.map((String choice) {
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

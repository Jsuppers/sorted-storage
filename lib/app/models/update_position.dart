import 'package:web/app/models/folder.dart';

class UpdatePosition {
  UpdatePosition(
      {required this.folder,
      required this.currentIndex,
      required this.targetIndex,
      required this.items,
      this.media});

  int currentIndex;
  int targetIndex;
  bool? media;
  List<dynamic> items;
  Folder? folder;
}

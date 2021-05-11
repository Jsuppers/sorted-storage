import 'package:web/app/models/story_content.dart';

class UpdatePosition {
  UpdatePosition(
      {
        required this.folderID,
        required this.currentIndex,
      required this.targetIndex,
      required this.items,
      this.media});

  int currentIndex;
  int targetIndex;
  bool? media;
  List<dynamic> items;
  String folderID;
}

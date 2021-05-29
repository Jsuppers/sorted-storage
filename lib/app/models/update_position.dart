// Project imports:
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/ui/widgets/folder_image.dart';

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

  Future<double?> getCurrentItemPosition() async {
    double? order;
    if (targetIndex == items.length - 1) {
      order = DateTime.now().millisecondsSinceEpoch.toDouble();
    } else if (targetIndex == 0) {
      order = getItemOrder(0);
      if (order != null) {
        order -= 1;
      }
    } else {
      final double? orderAbove = getItemOrder(targetIndex);
      final double? orderBelow = getItemOrder(targetIndex - 1);
      if (orderAbove != null && orderBelow != null) {
        order = (orderAbove + orderBelow) / 2;
      }
    }
    return order;
  }

  double? getItemOrder(int index) {
    if (media != null) {
      final FolderImage currentItem = (items as List<FolderImage>)[index];
      return currentItem.folderMedia.metadata.getTimestamp()!;
    }
    final Folder currentItem = (items as List<Folder>)[index];
    return currentItem.metadata.getTimestamp();
  }

  String? getCurrentItemId() {
    if (media != null) {
      final FolderImage currentItem =
          (items as List<FolderImage>)[currentIndex];
      return currentItem.folderMedia.id;
    }
    final Folder currentItem = (items as List<Folder>)[currentIndex];
    return currentItem.id;
  }

  Map<String, dynamic> getCurrentItemMetadata() {
    if (media != null) {
      final FolderImage currentItem =
          (items as List<FolderImage>)[currentIndex];
      return currentItem.folderMedia.metadata;
    }
    final Folder currentItem = (items as List<Folder>)[currentIndex];
    return currentItem.metadata;
  }
}

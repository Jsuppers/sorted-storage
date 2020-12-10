import 'package:googleapis/drive/v3.dart';

abstract class MediaCacheEvent {
  const MediaCacheEvent();
}

class MediaCacheGetImageEvent extends MediaCacheEvent {
  final String imageURL;

  MediaCacheGetImageEvent(this.imageURL);
}

class MediaCacheUpdateDriveAPIEvent extends MediaCacheEvent {
  final DriveApi driveApi;

  MediaCacheUpdateDriveAPIEvent(this.driveApi);
}

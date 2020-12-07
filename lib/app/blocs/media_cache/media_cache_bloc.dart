
import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/media_cache/media_cache_event.dart';
import 'package:web/app/services/url_service.dart';

class MediaCacheBloc extends Bloc<MediaCacheEvent, Uint8List> {
  Map<String, Uint8List> images;
  DriveApi driveApi;

  MediaCacheBloc() : super(null) {
    images = Map();
  }

  @override
  Stream<Uint8List> mapEventToState(MediaCacheEvent event) async* {
    if (event is MediaCacheGetImageEvent){
      yield await getImage(event.imageURL);
    }
    if (event is MediaCacheUpdateDriveAPIEvent) {
      this.driveApi = event.driveApi;
    }
  }

  Future<Uint8List> getImage(String key) async {
    if (images.containsKey(key)) {
      return images[key];
    }
    URLService.openURL("https://drive.google.com/file/d/" + key + "/view");

    Media mediaFile = await driveApi.files
        .get(key, downloadOptions: DownloadOptions.FullMedia);

    List<int> dataStore = [];
    await for (var data in mediaFile.stream) {
      print('receiving ${data.length}');
      dataStore.insertAll(dataStore.length, data);
    }
    Uint8List image = Uint8List.fromList(dataStore);
    images.putIfAbsent(key, () => image);
    return image;
  }

}
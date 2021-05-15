// Dart imports:
import 'dart:async';
import 'dart:convert';
import 'dart:developer';

// Package imports:
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder_content.dart';
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/folder_metadata.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/app/services/timeline_service.dart';
import 'package:web/constants.dart';

/// CloudStoriesBloc handles all the cloud changes of the timeline.
class CloudStoriesBloc extends Bloc<CloudStoriesEvent, CloudStoriesState> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  CloudStoriesBloc(
      {required this.storage,
      required this.navigationBloc})
      : super(const CloudStoriesState(CloudStoriesType.initialState));

  late NavigationBloc navigationBloc;
  FolderContent? rootFolder;
  GoogleDrive storage;

  @override
  Stream<CloudStoriesState> mapEventToState(CloudStoriesEvent event) async* {
    // ignore: missing_enum_constant_in_switch
    switch (event.type) {
      case CloudStoriesType.updateFolderPosition:
        _updatePosition(event.data as UpdatePosition);
        break;
      case CloudStoriesType.rootFolder:
        rootFolder = await _getCurrentUserRootFolder();
        yield CloudStoriesState(CloudStoriesType.rootFolder,
            data: rootFolder);
        break;
      case CloudStoriesType.deleteFolder:
        _deleteFolder(event.data as FolderContent);
        break;
//      case CloudStoriesType.createFolder:
//        final FolderContent parent = event.data as FolderContent;
//        final FolderContent? fp = await storage.createStory(parent.id);
//        yield CloudStoriesState(CloudStoriesType.createFolder, data: fp);
//        break;
      case CloudStoriesType.retrieveFolder:
        if (event.data != null) {
          yield CloudStoriesState(CloudStoriesType.retrieveFolder, data: event.data, folderID: event.folderID);
          break;
        }
        if (rootFolder != null && event.folderID == rootFolder!.id) {
          FolderContent.sortFolders(rootFolder!.subFolders);
          yield CloudStoriesState(CloudStoriesType.retrieveFolder, data: rootFolder, folderID: event.folderID);
        } else if (rootFolder != null) {
          final FolderContent? folder = TimelineService.getFolderWithID(event.folderID!, rootFolder);
          _createEventFromFolder(folder!.id!, folder: folder).then((value) => {
            add(CloudStoriesEvent(CloudStoriesType.retrieveFolder, data: value, folderID: event.folderID))
          });
        } else {
          _createEventFromFolder(event.folderID!).then((folder) {
            add(CloudStoriesEvent(CloudStoriesType.retrieveFolder, data: folder, folderID: event.folderID));
          });
        }
        break;
      case CloudStoriesType.refresh:
        yield CloudStoriesState(CloudStoriesType.refresh,
            error: event.error,
            folderID: event.folderID);
        break;
      case CloudStoriesType.newUser:
        rootFolder = null;
        yield const CloudStoriesState(CloudStoriesType.initialState);
        break;
      case CloudStoriesType.initialState:
        break;
    }
  }


  Future<void> _updatePosition(UpdatePosition updatePosition) async {
    final double? newOrder = await storage.updatePosition(updatePosition);
    updatePosition.items[updatePosition.currentIndex].setTimestamp(newOrder);
  }


  Future<String?> _deleteFolder(FolderContent fp) async {
    storage.delete(fp.id!).then((dynamic value) {
//      myFolders.remove(fp.id);
      navigationBloc.add(NavigatorPopEvent());
      add(CloudStoriesEvent(CloudStoriesType.retrieveFolder, data: fp, folderID: fp.id));
      return null;
    }, onError: (_) {
      return 'Error when deleting story';
    });
  }
//
//  Future<void> _getFolderDetails(FolderContent parent) async {
//    final FileList eventList = await storage.listFiles(
//        "mimeType='application/vnd.google-apps.folder' and '${parent.id}' in parents and trashed=false",
//        filter:
//        'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink,description)');
//    final List<Future<dynamic>> tasks = <Future<dynamic>>[];
//    for (final File file in eventList.files!) {
//      final double? order = double.tryParse(file.description!);
//
//      if (order != null) {
//        tasks.add(_createEventFromFolder(file.id!, file.name!, order).then((FolderContent subEvent) async {
////          final List<FolderContent> subFolders = <FolderContent>[];
////          for (final FolderContent subFolder in mainEvent.subFolders!) {
////            final FolderContent subStoryContent =
////                await _createEventFromFolder(subFolder.id!, subFolder.name!, subFolder.order!);
////            subFolders.add(subStoryContent);
////          }
////
////          final FolderContent data = FolderContent.createFromFolderName(
////              folderName,
////              file.name,
////              id: subFolder.id, order: subFolder.)
////          myFolders.putIfAbsent(mainEvent.id!, () => mainEvent);
//        }));
//      }
//    }
//    await Future.wait(tasks);
//  }

//  Future<StoryTimelineData?> _getViewEvent(String folderID) async {
//    final dynamic folder = await storage.getFile(folderID);
//    if (folder == null) {
//      return null;
//    }
//    final int? timestamp = int.tryParse(folder.name! as String);
//    if (timestamp == null) {
//      return null;
//    }
//    final FolderContent mainEvent =
//        await _createEventFromFolder(folderID, timestamp);
//
//    final List<FolderContent> subEvents = <FolderContent>[];
//    for (final SubEvent subEvent in mainEvent.subEvents!) {
//      subEvents
//          .add(await _createEventFromFolder(subEvent.id, subEvent.timestamp));
//    }
//    return StoryTimelineData(mainStory: mainEvent, subEvents: subEvents);
//  }

  Future<FolderContent> _createEventFromFolder(
      String folderID, {String? folderName, Map<String, dynamic>? metadata, FolderContent? folder}) async {
    if (folder != null && folder.loaded == true) {
      return folder;
    }
    final FileList filesInFolder = await storage.listFiles(
        "'$folderID' in parents and trashed=false",
        filter:
            'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink,description)');

    FolderContent? currentFolder = folder;
    final Map<String, FolderMedia> images = <String, FolderMedia>{};
    final List<FolderContent> subFolders = <FolderContent>[];
    int index = 0;
    for (final File file in filesInFolder.files!) {
      Map<String, dynamic>? metadata;
      if (file.description != null) {
        try {
          metadata = jsonDecode(file.description ?? '') as Map<String, dynamic>? ?? {};
        } catch (e) {
          metadata = {};
        }
      }

      if (file.mimeType!.startsWith('image/') ||
          file.mimeType!.startsWith('video/')) {
        final FolderMedia media = FolderMedia(
          id: file.id!,
          name: file.name!,
          isVideo: file.mimeType!.startsWith('video/'),
          retrieveThumbnail: true,
          thumbnailURL: file.thumbnailLink,
          metadata: metadata,
        );
        if (media.getTimestamp() == null) {
          media.setTimestamp((DateTime.now().millisecondsSinceEpoch + index).toDouble());
        }
        images.putIfAbsent(file.id!, () => media);
      }  else if (file.mimeType == 'application/vnd.google-apps.folder') {
        final FolderContent subFolder =
          FolderContent.createFromFolderName(
              folderName: file.name!, id: file.id!, metadata: metadata);
        if (subFolder.getTimestamp() == null) {
          subFolder.setTimestamp((DateTime.now().millisecondsSinceEpoch + index).toDouble());
        }
        subFolders.add(subFolder);
      } else {
        final FolderMedia media = FolderMedia(
            name: file.name!,
            id: file.id!,
            isDocument: true,
            thumbnailURL: file.thumbnailLink,
            retrieveThumbnail: true,
            metadata: metadata);
        if (media.getTimestamp() == null) {
          media.setTimestamp((DateTime.now().millisecondsSinceEpoch + index).toDouble());
        }
        images.putIfAbsent(file.id!, () => media);
      }
      index++;
    }

    currentFolder ??= FolderContent.createFromFolderName(
          folderName: folderName,
          id: folderID,
          metadata: metadata);

    if (currentFolder.getTimestamp() == null) {
      currentFolder.setTimestamp((DateTime.now().millisecondsSinceEpoch + index).toDouble());
    }
    // TODO images not showing when directly going to media
    currentFolder.images = images;
    currentFolder.subFolders = subFolders;
    currentFolder.loaded = true;

    return currentFolder;
  }

  Future<FolderContent> _getCurrentUserRootFolder() async {
    if (rootFolder != null) {
      return rootFolder!;
    }
    final String query =
        "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.rootFolder}' and trashed=false";
    final FileList folderParent = await storage.listFiles(query,
        filter:
        'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink,description)');
    File rootFile;
    Map<String, dynamic> metadata = {};
    if (folderParent.files!.isEmpty) {
      metadata[describeEnum(MetadataKeys.timestamp)] = DateTime.now().millisecondsSinceEpoch.toDouble();
      final File fileMetadata = File();
      fileMetadata.name = Constants.rootFolder;
      fileMetadata.mimeType = 'application/vnd.google-apps.folder';
      fileMetadata.description = jsonEncode(metadata);
      rootFile = await storage.createFile(fileMetadata);
    } else {
      rootFile = folderParent.files!.first;
      try {
        metadata = jsonDecode(rootFile.description ?? '') as Map<String, dynamic>? ?? {};
      } catch (e) {
        metadata = {};
      }
    }

    return _createEventFromFolder(rootFile.id!, folderName: rootFile.name!, metadata: metadata);
  }

//  Future<List<FolderContent>> _getFolders(String? folderID) async {
//    if (folderID == null) {
//      return [];
//    }
//    if (myFolders.isNotEmpty && myFolders.containsKey(folderID)) {
//      return myFolders[folderID]?.subFolders ?? <FolderContent>[];
//    }
//
//    final FileList filesInFolder = await storage.listFiles(
//        "'$folderID' in parents and trashed=false",
//        filter: 'files(id,name,description)');
//
//    final List<FolderContent> output = <FolderContent>[];
//    if (filesInFolder.files != null) {
//      filesInFolder.files!.forEach((File element) {
//        final double? order = double.tryParse(element.description!);
//        final FolderContent fp = FolderContent.createFromFolderName(
//            folderName: element.name!,
//            id: element.id!,
//            order: order);
//        output.add(fp);
//      });
//    }
//    return output;
//  }
}

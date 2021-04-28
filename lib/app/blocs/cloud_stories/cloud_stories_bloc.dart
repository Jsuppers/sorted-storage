import 'dart:async';

import 'package:emojis/emojis.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder_properties.dart';
import 'package:web/app/models/story_comments.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/story_settings.dart';
import 'package:web/app/models/sub_event.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/update_index.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/constants.dart';

/// CloudStoriesBloc handles all the cloud changes of the timeline.
class CloudStoriesBloc extends Bloc<CloudStoriesEvent, CloudStoriesState> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  CloudStoriesBloc(
      {required Map<String, StoryTimelineData> cloudStories,
      required this.storage,
      required this.navigationBloc})
      : super(CloudStoriesState(CloudStoriesType.initialState, cloudStories)) {
    _cloudStories = cloudStories;
    _folders = <FolderProperties>[];
  }

  late List<FolderProperties> _folders;
  late NavigationBloc navigationBloc;
  late Map<String, StoryTimelineData> _cloudStories;
  GoogleDrive storage;
  late String currentMediaFileId;
  late String rootFolderID;

  @override
  Stream<CloudStoriesState> mapEventToState(CloudStoriesEvent event) async* {
    switch (event.type) {
      case CloudStoriesType.updateAllFolders:
        _updatePositions().then((value) =>
            add(const CloudStoriesEvent(CloudStoriesType.retrieveFolders)));
        break;
      case CloudStoriesType.updateFolderPosition:
        _updatePosition(event.data as UpdateIndex).then((value) =>
            add(const CloudStoriesEvent(CloudStoriesType.retrieveFolders)));
        break;
      case CloudStoriesType.rootFolder:
        rootFolderID = await _getCurrentUserRootFolderID();
        yield CloudStoriesState(CloudStoriesType.rootFolder, _cloudStories,
            data: rootFolderID);
        break;
      case CloudStoriesType.deleteFolder:
        _deleteFolder(event.data as FolderProperties);
        break;
      case CloudStoriesType.createFolder:
        FolderProperties? fp = await _createFolder(event.folderID);
        if (fp != null) {
          _folders.add(fp);
        }
        yield CloudStoriesState(CloudStoriesType.createFolder, _cloudStories,
            data: fp);
        break;
      case CloudStoriesType.retrieveFolders:
        _folders = await _getFolders(event.folderID);
        yield CloudStoriesState(CloudStoriesType.retrieveFolders, _cloudStories,
            data: _folders);
        break;
      case CloudStoriesType.retrieveStory:
      case CloudStoriesType.retrieveStories:
        _getStories(event.folderID);
        break;
      case CloudStoriesType.refresh:
        yield CloudStoriesState(CloudStoriesType.refresh, _cloudStories,
            error: event.error,
            folderID: event.folderID,
            storyTimelineData: event.storyTimelineData);
        break;
      case CloudStoriesType.newUser:
        _cloudStories.clear();
        yield CloudStoriesState(CloudStoriesType.initialState, _cloudStories);
        break;
      default:
        break;
    }
  }

  Future<FolderProperties?> _createFolder(String? folderID) async {
    folderID ??= rootFolderID;
    final File fileMetadata = File();
    String title = '${Emojis.alienMonster} New Event';
    FolderProperties fp =
        FolderProperties.extractProperties('${Emojis.alienMonster} New Event');
    fileMetadata.name = title;
    fileMetadata.parents = [folderID];
    fileMetadata.mimeType = 'application/vnd.google-apps.folder';
    fileMetadata.description = fp.order.toString();
    final File rt = await storage.createFile(fileMetadata);
    fp.id = rt.id;
    return fp;
  }

  Future<void> _updatePositions() async {
    for (int i = 0; i < _folders.length; i++) {
      await storage.updatePosition(_folders[i].id!, _folders[i].order);
    }
  }

  Future<void> _updatePosition(UpdateIndex updateIndex) async {
    await storage.updatePosition(_folders[updateIndex.oldIndex].id!,
        _folders[updateIndex.newIndex].order);
    await storage.updatePosition(_folders[updateIndex.newIndex].id!,
        _folders[updateIndex.oldIndex].order);
    double? oldIndex = _folders[updateIndex.oldIndex].order;
    _folders[updateIndex.oldIndex].order = _folders[updateIndex.newIndex].order;
    _folders[updateIndex.newIndex].order = oldIndex;
  }

  void _getStories(String? folderID) {
    if (folderID == null) {
      return;
//      if (_cloudStories.isEmpty || _cloudStories[folderID] == null) {
//        _getViewEvent(folderID).then(
//            (StoryTimelineData? data) => add(CloudStoriesEvent(
//                CloudStoriesType.refresh,
//                folderID: folderID,
//                storyTimelineData: data)),
//            onError: (dynamic error) => add(CloudStoriesEvent(
//                CloudStoriesType.refresh,
//                error: error.toString())));
//      } else {
//        add(CloudStoriesEvent(CloudStoriesType.refresh,
//            folderID: folderID, storyTimelineData: _cloudStories[folderID]));
//      }
    }
    if (_cloudStories.isEmpty) {
//      _getMediaFolder(folderID).then((String value) {
//        currentMediaFileId = value;
      _getStoriesFromFolder(folderID).then(
          (_) => add(const CloudStoriesEvent(CloudStoriesType.refresh)),
          onError: (_) => add(const CloudStoriesEvent(CloudStoriesType.refresh,
              error: 'Error retrieving stories')));
//      },
//          onError: (_) => add(const CloudStoriesEvent(CloudStoriesType.refresh,
//              error: 'Error retrieving media')));
    } else {
      add(const CloudStoriesEvent(CloudStoriesType.refresh));
    }
  }

  Future<String?> _deleteFolder(FolderProperties fp) async {
    storage.delete(fp.id!).then((dynamic value) {
      _folders.remove(fp);
      navigationBloc.add(NavigatorPopEvent());
      add(const CloudStoriesEvent(CloudStoriesType.retrieveFolders));
      return null;
    }, onError: (_) {
      return 'Error when deleting story';
    });
  }

  Future<void> _getStoriesFromFolder(String folderID) async {
    final FileList eventList = await storage.listFiles(
        "mimeType='application/vnd.google-apps.folder' and '$folderID' in parents and trashed=false");
    final List<Future<dynamic>> tasks = <Future<dynamic>>[];
    for (final File file in eventList.files!) {
      final int? timestamp = int.tryParse(file.name!);

      if (timestamp != null) {
        tasks.add(_createEventFromFolder(file.id!, timestamp)
            .then((StoryContent mainEvent) async {
          final List<StoryContent> subEvents = <StoryContent>[];
          for (final SubEvent subEvent in mainEvent.subEvents!) {
            final StoryContent subStoryContent =
                await _createEventFromFolder(subEvent.id, subEvent.timestamp);
            subEvents.add(subStoryContent);
          }

          final StoryTimelineData data =
              StoryTimelineData(mainStory: mainEvent, subEvents: subEvents);
          _cloudStories.putIfAbsent(file.id!, () => data);
        }));
      }
    }
    await Future.wait(tasks);
  }

  Future<StoryTimelineData?> _getViewEvent(String folderID) async {
    final dynamic folder = await storage.getFile(folderID);
    if (folder == null) {
      return null;
    }
    final int? timestamp = int.tryParse(folder.name! as String);
    if (timestamp == null) {
      return null;
    }
    final StoryContent mainEvent =
        await _createEventFromFolder(folderID, timestamp);

    final List<StoryContent> subEvents = <StoryContent>[];
    for (final SubEvent subEvent in mainEvent.subEvents!) {
      subEvents
          .add(await _createEventFromFolder(subEvent.id, subEvent.timestamp));
    }
    return StoryTimelineData(mainStory: mainEvent, subEvents: subEvents);
  }

//  Future<String> _getMediaFolder() async {
//    String mediaFolderID;
//
//    final String query =
//        "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.rootFolder}' and trashed=false";
//    final FileList folderParent = await storage.listFiles(query);
//    String parentId;
//
//    if (folderParent.files!.isEmpty) {
//      final File fileMetadata = File();
//      fileMetadata.name = Constants.rootFolder;
//      fileMetadata.mimeType = 'application/vnd.google-apps.folder';
//      fileMetadata.description = "please don't modify this folder";
//      final File rt = await storage.createFile(fileMetadata);
//      parentId = rt.id!;
//    } else {
//      parentId = folderParent.files!.first.id!;
//    }
//
//    final String query2 =
//        "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.mediaFolder}' and '$parentId' in parents and trashed=false";
//    final FileList folder = await storage.listFiles(query2);
//
//    if (folder.files!.isEmpty) {
//      final File mediaFolder = File();
//      mediaFolder.name = Constants.mediaFolder;
//      mediaFolder.parents = <String>[parentId];
//      mediaFolder.mimeType = 'application/vnd.google-apps.folder';
//      mediaFolder.description = "please don't modify this folder";
//
//      final File folder = await storage.createFile(mediaFolder);
//      mediaFolderID = folder.id!;
//    } else {
//      mediaFolderID = folder.files!.first.id!;
//    }
//
//    return mediaFolderID;
//  }

  Future<StoryContent> _createEventFromFolder(
      String folderID, int timestamp) async {
    final FileList filesInFolder = await storage.listFiles(
        "'$folderID' in parents and trashed=false",
        filter:
            'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink,description)');

    String? settingsID;
    String? commentsID;
    final Map<String, StoryMedia> images = <String, StoryMedia>{};
    final List<SubEvent> subEvents = <SubEvent>[];
    for (final File file in filesInFolder.files!) {
      int? fileIndex;
      if (file.description != null) {
        fileIndex = int.tryParse(file.description!);
      }

      if (file.mimeType!.startsWith('image/') ||
          file.mimeType!.startsWith('video/')) {
        final StoryMedia media = StoryMedia(
          fileID: file.id!,
          name: file.name!,
          isVideo: file.mimeType!.startsWith('video/'),
          retrieveThumbnail: true,
          thumbnailURL: file.thumbnailLink,
        );
        if (fileIndex != null) {
          media.index = fileIndex;
        }

        images.putIfAbsent(file.id!, () => media);
      } else if (file.name == Constants.settingsFile) {
        settingsID = file.id!;
      } else if (file.name == Constants.commentsFile) {
        commentsID = file.id!;
      } else if (file.mimeType == 'application/vnd.google-apps.folder') {
        final int? timestamp = int.tryParse(file.name!);
        if (timestamp != null) {
          subEvents.add(SubEvent(file.id!, timestamp));
        }
      } else {
        final StoryMedia media = StoryMedia(
          name: file.name!,
          fileID: file.id!,
          isDocument: true,
          thumbnailURL: file.thumbnailLink,
          retrieveThumbnail: true,
        );
        if (fileIndex != null) {
          media.index = fileIndex;
        }
        images.putIfAbsent(file.id!, () => media);
      }
    }

    final StoryMetadata metadata = StoryMetadata.fromJson(
        settingsID, await storage.getJsonFile(settingsID));

    final StoryComments comments =
        StoryComments.fromJson(await storage.getJsonFile(commentsID));

    return StoryContent(
        timestamp: timestamp,
        images: images,
        metadata: metadata,
        comments: comments,
        commentsID: commentsID,
        subEvents: subEvents,
        folderID: folderID);
  }

  Future<String> _getCurrentUserRootFolderID() async {
    final String query =
        "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.rootFolder}' and trashed=false";
    final FileList folderParent = await storage.listFiles(query);
    String parentId;
    if (folderParent.files!.isEmpty) {
      final File fileMetadata = File();
      fileMetadata.name = Constants.rootFolder;
      fileMetadata.mimeType = 'application/vnd.google-apps.folder';
      fileMetadata.description = "please don't modify this folder";
      final File rt = await storage.createFile(fileMetadata);
      parentId = rt.id!;
    } else {
      parentId = folderParent.files!.first.id!;
    }
    return parentId;
  }

  Future<List<FolderProperties>> _getFolders(String? folderID) async {
    if (_folders != null && _folders.isNotEmpty) {
      return _folders;
    }
    if (folderID == null) {
      return [];
    }

    final FileList filesInFolder = await storage.listFiles(
        "'$folderID' in parents and trashed=false",
        filter: 'files(id,name,description)');

    List<FolderProperties> output = <FolderProperties>[];

    if (filesInFolder.files != null) {
      filesInFolder.files!.forEach((element) {
        double? order = double.tryParse(element.description!);
        FolderProperties? fp = FolderProperties.extractProperties(element.name!,
            id: element.id, order: order);
        if (fp != null) {
          output.add(fp);
        }
      });
    }
    return output;
  }
}

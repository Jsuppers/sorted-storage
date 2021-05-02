// Dart imports:
import 'dart:async';

// Package imports:
import 'package:emojis/emojis.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/folder_properties.dart';
import 'package:web/app/models/story_content.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/models/story_settings.dart';
import 'package:web/app/models/sub_event.dart';
import 'package:web/app/models/timeline_data.dart';
import 'package:web/app/models/update_position.dart';
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
    // ignore: missing_enum_constant_in_switch
    switch (event.type) {
      case CloudStoriesType.updateFolderPosition:
        _updatePosition(event.data as UpdatePosition).then((_) =>
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
        _folders.sort((FolderProperties a, FolderProperties b) =>
            a.order!.compareTo(b.order!));
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
      case CloudStoriesType.initialState:
        break;
      case CloudStoriesType.editStory:
        break;
    }
  }

  Future<FolderProperties?> _createFolder(String? folderID) async {
    final File fileMetadata = File();
    final FolderProperties fileProperties =
        FolderProperties.extractProperties('${Emojis.alienMonster} New Event');
    fileMetadata.name = '${Emojis.alienMonster} New Event';
    fileMetadata.parents = [folderID ?? rootFolderID];
    fileMetadata.mimeType = 'application/vnd.google-apps.folder';
    fileMetadata.description = fileProperties.order.toString();
    final File rt = await storage.createFile(fileMetadata);
    fileProperties.id = rt.id;
    return fileProperties;
  }

  Future<void> _updatePosition(UpdatePosition updatePosition) async {
    final double? newOrder = await storage.updatePosition(updatePosition);
    updatePosition.items[updatePosition.currentIndex].order = newOrder;
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
      _getStoriesFromFolder(folderID).then(
          (_) => add(const CloudStoriesEvent(CloudStoriesType.refresh)),
          onError: (_) => add(const CloudStoriesEvent(CloudStoriesType.refresh,
              error: 'Error retrieving stories')));
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

  Future<StoryContent> _createEventFromFolder(
      String folderID, int timestamp) async {
    final FileList filesInFolder = await storage.listFiles(
        "'$folderID' in parents and trashed=false",
        filter:
            'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink,description)');

    String? settingsID;
    final Map<String, StoryMedia> images = <String, StoryMedia>{};
    final List<SubEvent> subEvents = <SubEvent>[];
    for (final File file in filesInFolder.files!) {
      double? fileIndex;
      if (file.description != null) {
        fileIndex = double.tryParse(file.description!);
      }

      if (file.mimeType!.startsWith('image/') ||
          file.mimeType!.startsWith('video/')) {
        final StoryMedia media = StoryMedia(
          id: file.id!,
          name: file.name!,
          isVideo: file.mimeType!.startsWith('video/'),
          retrieveThumbnail: true,
          thumbnailURL: file.thumbnailLink,
        );
        if (fileIndex != null) {
          media.order = fileIndex;
        }

        images.putIfAbsent(file.id!, () => media);
      } else if (file.name == Constants.settingsFile) {
        settingsID = file.id!;
      } else if (file.mimeType == 'application/vnd.google-apps.folder') {
        final int? timestamp = int.tryParse(file.name!);
        if (timestamp != null) {
          subEvents.add(SubEvent(file.id!, timestamp));
        }
      } else {
        final StoryMedia media = StoryMedia(
            name: file.name!,
            id: file.id!,
            isDocument: true,
            thumbnailURL: file.thumbnailLink,
            retrieveThumbnail: true,
            order: fileIndex);
        images.putIfAbsent(file.id!, () => media);
      }
    }

    final StoryMetadata metadata = StoryMetadata.fromJson(
        settingsID, await storage.getJsonFile(settingsID));

    return StoryContent(
        timestamp: timestamp,
        images: images,
        metadata: metadata,
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

    final List<FolderProperties> output = <FolderProperties>[];
    if (filesInFolder.files != null) {
      filesInFolder.files!.forEach((element) {
        final double? order = double.tryParse(element.description!);
        final FolderProperties? fp = FolderProperties.extractProperties(
            element.name!,
            id: element.id,
            order: order);
        if (fp != null) {
          output.add(fp);
        }
      });
    }
    return output;
  }
}

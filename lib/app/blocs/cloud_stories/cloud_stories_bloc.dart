// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/blocs/cloud_stories/cloud_stories_event.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_state.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/models/folder_content.dart';
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/folder_metadata.dart';
import 'package:web/app/models/update_position.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/constants.dart';

/// CloudStoriesBloc handles all the cloud changes of the timeline.
class CloudStoriesBloc extends Bloc<CloudStoriesEvent, CloudStoriesState?> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  CloudStoriesBloc({required this.storage, required this.navigationBloc})
      : super(null);

  late NavigationBloc navigationBloc;
  FolderContent? rootFolder;
  Map<String, FolderContent?> cache = {};
  GoogleDrive storage;

  @override
  Stream<CloudStoriesState> mapEventToState(CloudStoriesEvent? event) async* {
    if (event == null) {
      return;
    }
    // ignore: missing_enum_constant_in_switch
    switch (event.type) {
      case CloudStoriesType.updateFolderPosition:
        _updatePosition(event.data as UpdatePosition);
        break;
      case CloudStoriesType.rootFolder:
        rootFolder = await _getCurrentUserRootFolder();
        yield CloudStoriesState(CloudStoriesType.rootFolder, data: rootFolder);
        break;
      case CloudStoriesType.retrieveFolder:
        FolderContent? folder = event.data as FolderContent?;
        if (folder == null && cache.containsKey(event.folderID)) {
          folder = cache[event.folderID];
        }
        FolderContent value = await _createEventFromFolder(event.folderID!,
            folder: folder, owner: folder?.owner != null && folder!.owner == true);
        cache.putIfAbsent(value.id!, () => value);
        yield CloudStoriesState(CloudStoriesType.retrieveFolder,
            data: value, folderID: event.folderID);
        break;
      case CloudStoriesType.refresh:
        yield CloudStoriesState(CloudStoriesType.refresh,
            error: event.error, folderID: event.folderID);
        break;
      case CloudStoriesType.newUser:
        rootFolder = null;
        cache.clear();
        // TODO logout
        break;
    }
  }

  Future<void> _updatePosition(UpdatePosition updatePosition) async {
    final double? newOrder = await storage.updatePosition(updatePosition);
    updatePosition.items[updatePosition.currentIndex].setTimestamp(newOrder);
  }

  Future<FolderContent> _createEventFromFolder(String folderID,
      {String? folderName,
       required bool owner,
      Map<String, dynamic>? metadata,
      FolderContent? folder}) async {
    if (folder != null && folder.loaded == true) {
      return folder;
    }
    final FileList filesInFolder = await storage.listFiles(
        "'$folderID' in parents and trashed=false",
        filter:
            'files(id,name,parents,mimeType,hasThumbnail,thumbnailLink,description, owners)');

    FolderContent? currentFolder = folder;
    final Map<String, FolderMedia> images = <String, FolderMedia>{};
    final List<FolderContent> subFolders = <FolderContent>[];
    int index = 0;
    for (final File file in filesInFolder.files!) {
      Map<String, dynamic>? metadata;
      if (file.description != null) {
        try {
          metadata =
              jsonDecode(file.description ?? '') as Map<String, dynamic>? ?? {};
        } catch (e) {
          metadata = {};
        }
      }
      bool subFolderOwner = false;
      if (file.owners != null) {
        for (final User user in file.owners!) {
          if (user.me == true) {
            subFolderOwner = true;
            break;
          }
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
          media.setTimestamp(
              (DateTime.now().millisecondsSinceEpoch + index).toDouble());
        }
        images.putIfAbsent(file.id!, () => media);
      } else if (file.mimeType == 'application/vnd.google-apps.folder') {
        final FolderContent subFolder = FolderContent.createFromFolderName(
            folderName: file.name!, owner: subFolderOwner, id: file.id!, metadata: metadata);
        if (subFolder.getTimestamp() == null) {
          subFolder.setTimestamp(
              (DateTime.now().millisecondsSinceEpoch + index).toDouble());
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
          media.setTimestamp(
              (DateTime.now().millisecondsSinceEpoch + index).toDouble());
        }
        images.putIfAbsent(file.id!, () => media);
      }
      index++;
    }

    currentFolder ??= FolderContent.createFromFolderName(
      owner: owner,
        folderName: folderName, id: folderID, metadata: metadata);

    if (currentFolder.getTimestamp() == null) {
      currentFolder.setTimestamp(
          (DateTime.now().millisecondsSinceEpoch + index).toDouble());
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
      metadata[describeEnum(MetadataKeys.timestamp)] =
          DateTime.now().millisecondsSinceEpoch.toDouble();
      final File fileMetadata = File();
      fileMetadata.name = Constants.rootFolder;
      fileMetadata.mimeType = 'application/vnd.google-apps.folder';
      fileMetadata.description = jsonEncode(metadata);
      rootFile = await storage.createFile(fileMetadata);
    } else {
      rootFile = folderParent.files!.first;
      try {
        metadata =
            jsonDecode(rootFile.description ?? '') as Map<String, dynamic>? ??
                {};
      } catch (e) {
        metadata = {};
      }
    }
    return _createEventFromFolder(rootFile.id!, owner: true,
        folderName: rootFile.name!, metadata: metadata);
  }
}

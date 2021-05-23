// Dart imports:
import 'dart:async';
import 'dart:convert';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:googleapis/drive/v3.dart';

// Project imports:
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_state.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/models/folder_metadata.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/constants.dart';

/// CloudStoriesBloc handles all the cloud changes of the timeline.
class FolderStorageBloc extends Bloc<FolderStorageEvent, FolderStorageState?> {
  /// The constructor sets the private timeline data and sets the state to
  /// initial_state
  FolderStorageBloc({required this.storage, required this.navigationBloc})
      : super(null);

  late NavigationBloc navigationBloc;
  Folder? rootFolder;
  Map<String, Folder?> cache = <String, Folder?>{};
  GoogleDrive storage;

  @override
  Stream<FolderStorageState> mapEventToState(FolderStorageEvent? event) async* {
    if (event == null) {
      return;
    }
    switch (event.type) {
      case FolderStorageType.getRootFolder:
        yield await _getRootFolder();
        break;
      case FolderStorageType.getFolder:
        yield await _getFolder(event);
        break;
      case FolderStorageType.refresh:
        yield _refresh(event);
        break;
      case FolderStorageType.newUser:
        _newUser();
        break;
    }
  }

  Future<FolderStorageState> _getRootFolder() async {
    if (rootFolder == null) {
      final String query =
          "mimeType='application/vnd.google-apps.folder' and trashed=false and name='${Constants.rootFolder}' and trashed=false";
      final FileList folderParent =
          await storage.listFiles(query, filter: GoogleDrive.folderFilter);
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
      rootFolder = await _updateFolderData(rootFile.id!,
          folderName: rootFile.name!, metadata: metadata);
      rootFolder?.isRootFolder = true;
    }
    return FolderStorageState(FolderStorageType.getRootFolder,
        data: rootFolder);
  }

  Future<FolderStorageState> _getFolder(FolderStorageEvent event) async {
    Folder? folder = event.data as Folder?;
    if (folder == null && cache.containsKey(event.folderID)) {
      folder = cache[event.folderID];
    }
    folder = await _updateFolderData(event.folderID!, folder: folder);
    cache.putIfAbsent(folder.id!, () => folder);
    return FolderStorageState(FolderStorageType.getFolder,
        data: folder, folderID: event.folderID);
  }

  Future<Folder> _updateFolderData(String folderID,
      {String? folderName,
      Map<String, dynamic>? metadata,
      Folder? folder}) async {
    if (folder != null && folder.loaded == true) {
      return folder;
    }
    final FileList filesInFolder = await storage.listFiles(
        "'$folderID' in parents and trashed=false",
        filter: GoogleDrive.folderFilter);

    Folder? currentFolder = folder ??
        Folder.createFromFolderName(
            folderName: folderName, id: folderID, metadata: metadata);

    final Map<String, FolderMedia> images = <String, FolderMedia>{};
    final List<Folder> subFolders = <Folder>[];
    int index = 0;
    for (final File file in filesInFolder.files!) {
      Map<String, dynamic>? metadata = {};
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
        final Folder subFolder = Folder.createFromFolderName(
            folderName: file.name!,
            owner: subFolderOwner,
            parent: currentFolder,
            id: file.id!,
            metadata: metadata);
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

    if (currentFolder.getTimestamp() == null) {
      currentFolder.setTimestamp(
          (DateTime.now().millisecondsSinceEpoch + index).toDouble());
    }
    currentFolder.images = images;
    currentFolder.subFolders = subFolders;
    currentFolder.loaded = true;
    currentFolder.amOwner ??= await storage.amOwner(folderID);

    return currentFolder;
  }

  FolderStorageState _refresh(FolderStorageEvent event) {
    return FolderStorageState(FolderStorageType.refresh,
        error: event.error, folderID: event.folderID, data: event.data);
  }

  void _newUser() {
    rootFolder = null;
    cache.clear();
  }
}

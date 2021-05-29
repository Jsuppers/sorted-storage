// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_state.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/services/cloud_provider/google/google_drive.dart';

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
    rootFolder ??= await storage.getRootFolder();
    return FolderStorageState(FolderStorageType.getRootFolder,
        data: rootFolder);
  }

  Future<FolderStorageState> _getFolder(FolderStorageEvent event) async {
    Folder? folder = event.data as Folder?;
    if (folder == null && cache.containsKey(event.folderID)) {
      folder = cache[event.folderID];
    }
    if (folder != null) {
      await storage.updateFolder(event.folderID!, folder: folder);
    } else {
      folder = await storage.getFolder(event.folderID!);
    }
    cache.putIfAbsent(folder.id!, () => folder);
    return FolderStorageState(FolderStorageType.getFolder,
        data: folder, folderID: event.folderID);
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

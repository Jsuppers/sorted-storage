// Package imports:
import 'package:bloc/bloc.dart';

// Project imports:
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/app/models/sharing_information.dart';
import 'package:web/app/services/cloud_provider/google/google_drive.dart';

/// SharingBloc handles creating and delete permissions for a folder to allow
/// This folder to be shared or un-shared
class SharingBloc extends Bloc<ShareEvent, SharingInformation?> {
  /// constructor
  SharingBloc(String folderID, GoogleDrive storage) : super(null) {
    _folderID = folderID;
    _storage = storage;
    add(InitialEvent());
  }

  late String _folderID;
  late GoogleDrive _storage;

  @override
  Stream<SharingInformation> mapEventToState(ShareEvent event) async* {
    switch (event.runtimeType) {
      case InitialEvent:
        yield await _storage.isShared(_folderID);
        break;
      case StartSharingEvent:
        yield await _storage.shareFolder(_folderID);
        break;
      case StopSharingEvent:
        yield await _storage.stopSharingFolder(_folderID);
        break;
    }
  }
}

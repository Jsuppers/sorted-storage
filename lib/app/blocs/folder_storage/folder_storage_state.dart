// Project imports:
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';

/// State returned
class FolderStorageState {
  /// The state contains the type of state and a copy of the cloud timeline
  const FolderStorageState(this.type, {this.folderID, this.error, this.data});

  /// type of state
  final FolderStorageType type;

  /// generic data passed in the state
  final dynamic data;

  /// the folder ID for the related folder
  final String? folderID;

  /// error message
  final String? error;
}

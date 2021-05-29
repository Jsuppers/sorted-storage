// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:web/app/models/folder_metadata.dart';

/// extension to easily get/set common values from a map
/// to use don't forget to import 'package:web/app/extensions/metadata.dart';
extension MetaDataExtension on Map<String, dynamic> {
  double? getTimestamp() {
    return this[describeEnum(MetadataKeys.timestamp)] as double?;
  }

  void setTimestamp(double? timestamp) {
    this[describeEnum(MetadataKeys.timestamp)] = timestamp;
  }

  void setTimestampIfEmpty(double? timestamp) {
    if (this[describeEnum(MetadataKeys.timestamp)] != null) {
      return;
    }
    this[describeEnum(MetadataKeys.timestamp)] = timestamp;
  }

  void setTimestampNow() {
    this[describeEnum(MetadataKeys.timestamp)] =
        DateTime.now().millisecondsSinceEpoch.toDouble();
  }

  String getDescription() {
    return this[describeEnum(MetadataKeys.description)] as String? ?? '';
  }

  void setDescription(String? description) {
    this[describeEnum(MetadataKeys.description)] = description;
  }
}

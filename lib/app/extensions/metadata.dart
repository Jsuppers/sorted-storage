// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/theme_data.dart';

enum MetadataKeys {
  /// timestamp allows the folder/file to have a certain date
  timestamp,

  /// description allows a small description of what the resource is about
  description,

  /// order is used to sort the resource e.g. folders in the home screen
  /// can be moved around
  order,

  /// type is used to describe which layout to use
  layout,

  /// if type is custom it will search for the value for this key and display
  /// this in a web view
  customURL,

  /// theme data allows the user to customize the color of the app
  themeData,
}

/// extension to easily get/set common values from a map
/// to use don't forget to import 'package:web/app/extensions/metadata.dart';
extension MetaDataExtension on Map<String, dynamic> {
  ThemeData? getThemeData() {
    return this[describeEnum(MetadataKeys.themeData)] as ThemeData?;
  }

  void setThemeData(ThemeData? themeData) {
    this[describeEnum(MetadataKeys.themeData)] = themeData;
  }

  FolderLayout? getLayout() {
    return this[describeEnum(MetadataKeys.layout)] as FolderLayout?;
  }

  void setLayout(FolderLayout? layout) {
    this[describeEnum(MetadataKeys.layout)] = layout;
  }

  String? getCustomURL() {
    return this[describeEnum(MetadataKeys.customURL)] as String?;
  }

  void setCustomURL(String? customURL) {
    this[describeEnum(MetadataKeys.customURL)] = customURL;
  }

  int? getTimestamp() {
    return this[describeEnum(MetadataKeys.timestamp)] as int?;
  }

  void setTimestamp(int? timestamp) {
    this[describeEnum(MetadataKeys.timestamp)] = timestamp;
  }

  double? getOrder() {
    return this[describeEnum(MetadataKeys.order)] as double?;
  }

  void setOrder(double? order) {
    this[describeEnum(MetadataKeys.order)] = order;
  }

  void setOrderIfEmpty(double? order) {
    if (this[describeEnum(MetadataKeys.order)] != null) {
      return;
    }
    this[describeEnum(MetadataKeys.order)] = order;
  }

  void setTimestampIfEmpty(int? timestamp) {
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

// Dart imports:
import 'dart:convert';

enum MetadataKeys { timestamp, description, order }

class MetaData {
  static Map<String, dynamic> fromString(String? string) {
    if (string == null) {
      return <String, dynamic>{};
    }
    try {
      return jsonDecode(string) as Map<String, dynamic>? ?? <String, dynamic>{};
    } catch (e) {
      return <String, dynamic>{};
    }
  }
}

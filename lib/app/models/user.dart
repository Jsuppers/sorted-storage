/// information about a user
class User {
  // ignore: public_member_api_docs
  User(
      {required this.displayName,
      required this.headers,
      required this.photoUrl,
      required this.email});

  /// email address of this user
  final String email;

  /// display name of this user
  final String displayName;

  /// url of a photo for this user
  final String photoUrl;

  /// auth headers for this user
  final Future<Map<String, String>> headers;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}

/// information about a user
class User {
  // ignore: public_member_api_docs
  User(
      {this.displayName,
        this.headers,
        this.photoUrl,
        this.email});

  /// email address of this user
  final String email;

  /// display name of this user, used when sending comments
  final String displayName;

  /// url of a photo for this user
  final String photoUrl;

  /// auth headers for this user
  final Map<String, String> headers;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'name': displayName,
      'email': email,
      'photoUrl': photoUrl,
    };
  }
}

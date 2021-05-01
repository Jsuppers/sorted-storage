/// route enums
enum BaseRoute {
  documents,
  media,
  view,
  login,
  policy,
  terms,
  error,
  home,
  profile,
  folders
}

extension ParseToString on BaseRoute {
  String toRouteString() {
    return '/${toString().split('.').last}';
  }
}
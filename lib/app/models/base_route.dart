/// route enums
enum BaseRoute {
  login,
  policy,
  terms,
  error,
  home,
  folder,
  profile,
  folders
}

extension ParseToString on BaseRoute {
  String toRouteString() {
    return '/${toString().split('.').last}';
  }
}

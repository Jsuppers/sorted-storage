/// route enums
enum BaseRoute {
  login,
  policy,
  terms,
  error,
  about,
  folders,
  folder,
  profile,
  home,
  show
}

extension ParseToString on BaseRoute {
  String toRouteString() {
    return '/${toString().split('.').last}';
  }
}

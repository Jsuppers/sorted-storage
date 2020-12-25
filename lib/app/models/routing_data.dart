/// information needed for routing
class RoutingData {
  // ignore: public_member_api_docs
  RoutingData(
      {this.destination, this.baseRoute, this.route, this.queryParameters});

  /// full route
  final String route;

  /// first part of the route
  final String baseRoute;

  /// destination of route i.e. a certain story
  final String destination;

  /// query parameters in the route
  final Map<String, String> queryParameters;
}

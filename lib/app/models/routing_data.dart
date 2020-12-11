class RoutingData {
  final String route;
  final String baseRoute;
  final String destination;
  final Map<String, String> queryParameters;

  RoutingData({this.destination, this.baseRoute, this.route, this.queryParameters});
}

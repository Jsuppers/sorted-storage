import 'package:web/app/models/routing_data.dart';

/// string extensions allow extra functionality on strings
extension StringExtensions on String {
  static const String _uriRegex = '(/.*?)(/.*)';

  /// gets the route, base route, destination and query parameters
  RoutingData get getRoutingData {
    final Uri uriData = Uri.parse(this);
    final RegExp regExp = RegExp(_uriRegex);
    final Iterable<RegExpMatch> matches = regExp.allMatches(uriData.path);
    String baseRoute = uriData.path;
    String destination = '';
    if (matches.isNotEmpty) {
      final RegExpMatch match = matches.elementAt(0);
      baseRoute = match.group(1);
      destination = match.group(2).replaceFirst('/', '');
    }

    return RoutingData(
      queryParameters: uriData.queryParameters,
      route: uriData.path,
      baseRoute: baseRoute,
      destination: destination,
    );
  }
}

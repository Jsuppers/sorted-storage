import 'package:web/app/models/routing_data.dart';

extension StringExtensions on String {
  static String uriRegex = r'(/.*?)(/.*)';

  RoutingData get getRoutingData {
    var uriData = Uri.parse(this);
    RegExp regExp = new RegExp(uriRegex);
    var matches = regExp.allMatches(uriData.path);
    var baseRoute = uriData.path;
    var destination = "";
    if (matches.length >= 1) {
      var match = matches.elementAt(0);
      baseRoute = match.group(1);
      destination = match.group(2).replaceFirst("/", "");
    }

    print("Routing Path:");
    print(" route: ${uriData.path}");
    print(" baseRoute: $baseRoute");
    print(" destination: $destination");
    print(" queryParameters: ${uriData.queryParameters}");
    return RoutingData(
      queryParameters: uriData.queryParameters,
      route: uriData.path,
      baseRoute: baseRoute,
      destination: destination,
    );
  }
}


import 'package:flutter_test/flutter_test.dart';
import 'package:web/app/extensions/string_extensions.dart';
import 'package:web/app/models/routing_data.dart';

main() {
  group('StringExtensions', () {
    test(
        'Given a route When we call getRoutingData than we should return the correct routing data',
            () async {
          String viewRoute = "/view/123?foo=bar";

          RoutingData mediaRoutingData = viewRoute.getRoutingData;

          expect(mediaRoutingData.baseRoute, "/view");
          expect(mediaRoutingData.destination, "123");
          expect(mediaRoutingData.route, "/view/123");
          expect(mediaRoutingData.queryParameters, {"foo": "bar"});
        });

    test(
        'Given a invalid route When we call getRoutingData than we should return / as base route',
            () async {
          String viewRoute = "this%20is%20invalid";

          RoutingData mediaRoutingData = viewRoute.getRoutingData;

          expect(mediaRoutingData.baseRoute, viewRoute);
          expect(mediaRoutingData.destination, "");
          expect(mediaRoutingData.queryParameters, {});
        });
  });

}

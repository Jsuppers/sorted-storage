import 'package:flutter/services.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:web/app/services/url_service.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;



main() {
  test('Given When Then', () {
    final List<MethodCall> log = <MethodCall>[];

    MethodChannel channel = const MethodChannel('package:url_launcher/url_launcher.dart');

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
    });

    URLService.openURL("http://example.com/");

    //expect(log, equals(<MethodCall>[new MethodCall('canLaunch', "http://example.com/")]));


  });
}

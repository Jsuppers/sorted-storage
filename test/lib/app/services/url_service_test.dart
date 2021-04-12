import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test/test.dart';
import 'package:web/app/services/url_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  test(
      'Given a valid url When openURL is called '
          'Then the url should be launched',
      () async {
    final List<MethodCall> log = <MethodCall>[];

    MethodChannel channel =
        const MethodChannel('plugins.flutter.io/url_launcher');

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return true;
    });
    const String exampleURL = 'http://foo.bar';
    await URLService.openURL(exampleURL);

    expect(log.first.method, 'canLaunch');
    expect(log.first.arguments['url'], exampleURL);
    expect(log.last.method, 'launch');
    expect(log.last.arguments['url'], exampleURL);
    expect(log.length, 2);
  });

  test(
      'Given a invalid url When openURL is called '
          'Then a exception should be thrown',
      () async {
    final List<MethodCall> log = <MethodCall>[];

    MethodChannel channel =
        const MethodChannel('plugins.flutter.io/url_launcher');

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return false;
    });
    const String exampleURL = 'http://foo.bar';
    try {
      await URLService.openURL(exampleURL);
      assert(false);
    } catch (e) {
      print('exception should be called');
    }
    expect(log.first.method, 'canLaunch');
    expect(log.first.arguments['url'], exampleURL);
    expect(log.length, 1);
  });

  test(
      'Given a image key When openDriveMedia is called '
          'Then the correct google drive link should be opened',
      () async {
    final List<MethodCall> log = <MethodCall>[];

    MethodChannel channel =
        const MethodChannel('plugins.flutter.io/url_launcher');

    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      log.add(methodCall);
      return true;
    });
    String imageKey = 'foo';
    String expectedURL = 'https://drive.google.com/file/d/foo/view';
    await URLService.openDriveMedia(imageKey);

    expect(log.first.method, 'canLaunch');
    expect(log.first.arguments['url'], expectedURL);
    expect(log.last.method, 'launch');
    expect(log.last.arguments['url'], expectedURL);
    expect(log.length, 2);
  });
}

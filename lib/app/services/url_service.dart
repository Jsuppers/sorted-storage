import 'package:url_launcher/url_launcher.dart';

/// service which allows navigation to external urls
class URLService {
  /// opens the media in a google drive view
  static Future<void> openDriveMedia(String imageKey) async {
    openURL('https://drive.google.com/file/d/$imageKey/view');
  }

  /// opens a external url
  static Future<void> openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

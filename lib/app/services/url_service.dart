import 'package:url_launcher/url_launcher.dart';

class URLService {
  static Future openDriveMedia(String imageKey) async {
    openURL("https://drive.google.com/file/d/" + imageKey + "/view");
  }

  static Future openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

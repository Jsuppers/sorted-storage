import 'package:url_launcher/url_launcher.dart';

class URLService {
  static void openDriveMedia(String imageKey) async {
    openURL("https://drive.google.com/file/d/" + imageKey + "/view");
  }

  static void openURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}

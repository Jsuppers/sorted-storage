import 'package:flutter/material.dart';
import 'package:web/app/models/page_content.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/pages/template/page_template.dart';

class HomePage extends StatelessWidget {
  static const String route = '/home';

  final List<PageContent> content = [
    PageContent(
        title: "About",
        text:
            "Welcome to SortedStorage.com! this site was created as a means to sort "
            "your cloud storage files in a nice way so that you can share it with friends and family. "
            "SortedStorage.com was built with three things in mind: keeping your privacy, being open source, and being free",
        imageUri: "assets/images/about.png"),
    PageContent(
        title: "Privacy",
        text: "SortedStorage.com simply acts as a middleman between you and "
            "your cloud storage provider. We cannot see and do not store any account information or anything "
            "you upload, this is between you and your cloud storage provider. "
            "Don't believe me? good you shouldn't believe anyone blindly, therefore, this project is open source, "
            "anyone can see exactly what happens under the hood",
        imageUri: "assets/images/privacy.png"),
    PageContent(
        title: "Open Source",
        text:
            "If you are a developer or just curious about the code please visit https://github.com/Jsuppers/sorted-storage. "
            "There are still many features this project wants to achieve, so if you are a developer please consider "
            "contributing.",
        imageUri: "assets/images/open_source.png",
        callToActionCallback: () => URLService.openURL(Constants.GITHUB_URL),
        callToActionButtonText: "Github"),
    PageContent(
        title: "Free",
        text:
            "This site does not charge you anything, it only asks you use this site with a smile :). If you want to support this"
            " project and help fund further improvements and features please consider donating!",
        imageUri: "assets/images/free.png",
        callToActionButtonText: "Donate",
        callToActionCallback: () => URLService.openURL(Constants.DONATE_URL))
  ];

  @override
  Widget build(BuildContext context) {
    return PageTemplate(content);
  }
}

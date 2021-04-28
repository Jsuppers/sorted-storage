// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:web/app/models/page_content.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/constants.dart';
import 'package:web/ui/pages/template/page_template.dart';

/// home page
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<PageItemContent> content = <PageItemContent>[
      PageItemContent(
          title: 'About',
          text:
              'Welcome to SortedStorage.com! this site was created as a means '
              'to sort your cloud storage files in a nice way so that you can '
              'share it with friends and family. SortedStorage.com was built '
              'with three things in mind: keeping your privacy, being open '
              'source, and being free',
          imageURL: 'assets/images/about.png'),
      PageItemContent(
          title: 'Privacy',
          text: 'SortedStorage.com simply acts as a middleman between you and '
              'your cloud storage provider. We cannot see and do not store any '
              'account information or anything you upload, this is between you '
              'and your cloud storage provider. Are you sceptical? good you sh '
              "ouldn't believe anyone blindly, therefore, this project is open "
              'source, anyone can see exactly what happens under the hood',
          imageURL: 'assets/images/privacy.png'),
      PageItemContent(
          title: 'Open Source',
          text: 'If you are a developer or just curious about the code please '
              'visit https://github.com/Jsuppers/sorted-storage. There are '
              'still many features this project wants to achieve, so if you '
              'are a developer please consider contributing.',
          imageURL: 'assets/images/open_source.png',
          callToActionCallback: () => URLService.openURL(Constants.githubURL),
          callToActionButtonText: 'Github'),
      PageItemContent(
          title: 'Free',
          text: 'This site does not charge you anything, it only asks you use '
              'this site with a smile :). If you want to support this project '
              'and help fund further improvements and features please consider '
              'donating!',
          imageURL: 'assets/images/free.png',
          callToActionButtonText: 'Donate',
          callToActionCallback: () => URLService.openURL(Constants.donateURL))
    ];

    return PageTemplate(content);
  }
}

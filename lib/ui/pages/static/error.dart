// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:web/app/models/page_content.dart';
import 'package:web/ui/pages/template/page_template.dart';

/// Error page
class ErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<PageItemContent> content = <PageItemContent>[
      PageItemContent(
          title: 'Something went wrong',
          text: 'please try again',
          imageURL: 'assets/images/error.png')
    ];

    return PageTemplate(content);
  }
}

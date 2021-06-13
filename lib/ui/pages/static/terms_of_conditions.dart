// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:web/app/models/page_content.dart';
import 'package:web/ui/pages/template/page_template.dart';

/// Terms page
class TermsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String file = 'assets/docs/terms.txt';
    return FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(file),
        builder: (BuildContext context, AsyncSnapshot<String> document) {
          final List<PageItemContent> content = <PageItemContent>[
            PageItemContent(
              title: 'Terms of Conditions',
              text: document.data ?? '',
            )
          ];
          return Card(child: PageTemplate(content));
        });
  }
}

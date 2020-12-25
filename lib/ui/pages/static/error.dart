import 'package:flutter/material.dart';
import 'package:web/app/models/page_content.dart';
import 'package:web/ui/pages/template/page_template.dart';

class ErrorPage extends StatelessWidget {
  static const String route = '/error';

  final List<PageItemContent> content = [
    PageItemContent(
        title: "Something went wrong",
        text: "please try again",
        imageURL: "assets/images/error.png")
  ];

  @override
  Widget build(BuildContext context) {
    return PageTemplate(content);
  }
}

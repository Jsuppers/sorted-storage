import 'package:flutter/material.dart';

class DocumentsPage extends StatefulWidget {
  static const String route = '/documents';

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("documents"),
      ],
    );
  }
}

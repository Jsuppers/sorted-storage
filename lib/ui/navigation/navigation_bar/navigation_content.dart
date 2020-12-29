import 'package:flutter/material.dart';

/// Formatting of navigation content
class NavigationContent extends StatelessWidget {
  // ignore: public_member_api_docs
  const NavigationContent(this._children, {Key key}) : super(key: key);

  final List<Widget> _children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: _children),
    );
  }
}

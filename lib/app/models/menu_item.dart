import 'package:flutter/material.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';

/// A item for the menu
class MenuItem {
  // ignore: public_member_api_docs
  MenuItem({this.text, this.icon, this.event});


  String text;
  IconData icon;
  NavigationEvent event;
}

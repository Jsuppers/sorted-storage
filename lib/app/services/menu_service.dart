import 'package:flutter/material.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/menu_item.dart';

/// Service for creating the menu
class MenuService {
  /// items which are both in the drawer and navigation bar
  static List<MenuItem> commonItems() => <MenuItem>[
        MenuItem(text: 'Home', icon: Icons.home, event: NavigateToHomeEvent()),
      ];

  /// items which are shown when logged in
  static List<MenuItem> dashboardItems() => <MenuItem>[
        MenuItem(
            text: 'Media', icon: Icons.image, event: NavigateToMediaEvent()),
        MenuItem(
            text: 'Documents',
            icon: Icons.folder,
            event: NavigateToDocumentsEvent()),
      ];
}

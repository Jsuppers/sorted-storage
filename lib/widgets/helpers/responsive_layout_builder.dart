// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import 'package:sorted_storage/layout/layout.dart';

/// Signature for the individual builders (`small`, `medium`, etc.).
typedef ResponsiveLayoutWidgetBuilder = Widget Function(BuildContext, Widget?);

/// {@template responsive_layout_builder}
/// A wrapper around [LayoutBuilder] which exposes builders for
/// various responsive breakpoints.
/// {@endtemplate}
class ResponsiveLayoutBuilder extends StatelessWidget {
  /// {@macro responsive_layout_builder}
  const ResponsiveLayoutBuilder({
    Key? key,
    required this.small,
    required this.medium,
    required this.large,
    required this.xLarge,
    this.child,
  }) : super(key: key);

  /// [ResponsiveLayoutWidgetBuilder] for small layout.
  final ResponsiveLayoutWidgetBuilder small;

  /// [ResponsiveLayoutWidgetBuilder] for medium layout.
  final ResponsiveLayoutWidgetBuilder medium;

  /// [ResponsiveLayoutWidgetBuilder] for large layout.
  final ResponsiveLayoutWidgetBuilder large;

  /// [ResponsiveLayoutWidgetBuilder] for xLarge layout.
  final ResponsiveLayoutWidgetBuilder xLarge;

  /// Optional child widget which will be passed to
  /// builders as a way to share/optimize shared layout.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < ScreenBreakpoints.small) {
          DeviceScreenSize.screenSize = ScreenSize.small;
          AppSpacings.scaleFactor = ScreenScaleFactors.smallScaleFactor;
          return small(context, child);
        } else if (constraints.maxWidth < ScreenBreakpoints.medium) {
          DeviceScreenSize.screenSize = ScreenSize.medium;
          AppSpacings.scaleFactor = ScreenScaleFactors.mediumScaleFactor;
          return medium(context, child);
        } else if (constraints.maxWidth < ScreenBreakpoints.large) {
          DeviceScreenSize.screenSize = ScreenSize.large;
          AppSpacings.scaleFactor = ScreenScaleFactors.largeScaleFactor;
          return large(context, child);
        } else {
          DeviceScreenSize.screenSize = ScreenSize.xLarge;
          AppSpacings.scaleFactor = ScreenScaleFactors.xLargeScaleFactor;
          return xLarge(context, child);
        }
      },
    );
  }
}

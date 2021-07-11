// Flutter imports:
import 'package:flutter/material.dart';

class LandingFabExtenderButton extends StatelessWidget {
  const LandingFabExtenderButton({
    Key? key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  final Icon icon;
  final String title;
  final Color color;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    final _theme = Theme.of(context);

    return Card(
      shape: const StadiumBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconTheme(data: IconThemeData(color: color), child: icon),
              const SizedBox(width: 8),
              Text(
                title,
                style: _theme.textTheme.subtitle1!.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

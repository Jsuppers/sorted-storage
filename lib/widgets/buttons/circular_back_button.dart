import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:sorted_storage/layout/layout.dart';

class CircularBackButton extends StatelessWidget {
  const CircularBackButton({Key? key, required this.onTap}) : super(key: key);
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: EdgeInsets.all(AppSpacings.eight),
        child: const Icon(EvaIcons.arrowIosBack),
      ),
    );
  }
}

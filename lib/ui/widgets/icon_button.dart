// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:web/constants.dart';

/// A button which is responsive and shows a icon with a text
class ButtonWithIcon extends StatelessWidget {
  // ignore: public_member_api_docs
  const ButtonWithIcon(
      {Key? key,
      required this.text,
      required this.icon,
      required this.width,
      required this.onPressed,
      required this.backgroundColor,
      this.iconColor = Colors.white,
      this.textColor = Colors.white})
      : super(key: key);

  // ignore: public_member_api_docs
  final String text;
  // ignore: public_member_api_docs
  final IconData icon;
  // ignore: public_member_api_docs
  final Function onPressed;
  // ignore: public_member_api_docs
  final Color iconColor;
  // ignore: public_member_api_docs
  final Color backgroundColor;
  // ignore: public_member_api_docs
  final Color textColor;
  // ignore: public_member_api_docs
  final double width;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      elevation: 0,
      hoverElevation: 0,
      focusElevation: 0,
      highlightElevation: 0,
      minWidth: width >= Constants.minScreenWidth ? 100 : 30,
      color: backgroundColor,
      textColor: textColor,
      onPressed: () => onPressed(),
      child: width >= Constants.minScreenWidth
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  icon,
                  color: iconColor,
                ),
                const SizedBox(width: 5),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.0,
                    fontFamily: 'Roboto',
                    color: textColor,
                  ),
                ),
              ],
            )
          : Icon(
              icon,
              color: iconColor,
            ),
    );
  }
}

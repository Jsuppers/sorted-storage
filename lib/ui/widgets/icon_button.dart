import 'package:flutter/material.dart';
import 'package:web/constants.dart';

/// A button which is responsive and shows a icon with a text
class ButtonWithIcon extends StatelessWidget {
  // ignore: public_member_api_docs
  const ButtonWithIcon(
      {Key key,
      this.text,
      this.icon,
      this.onPressed,
      this.iconColor = Colors.white,
      this.backgroundColor,
      this.textColor = Colors.white,
      this.width})
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

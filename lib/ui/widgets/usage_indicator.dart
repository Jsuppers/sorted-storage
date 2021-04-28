// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:percent_indicator/percent_indicator.dart';

// Project imports:
import 'package:web/ui/theme/theme.dart';

/// shows the cloud storage usage
class UsageIndicator extends StatelessWidget {
  // ignore: public_member_api_docs
  const UsageIndicator(
      {Key? key,
      required this.limit,
      required this.usage,
      required this.percent})
      : super(key: key);

  // ignore: public_member_api_docs
  final String limit;

  // ignore: public_member_api_docs
  final String usage;

  // ignore: public_member_api_docs
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              usage,
              style: myThemeData.textTheme.bodyText1,
            ),
            Text(
              limit,
              style: myThemeData.textTheme.bodyText1,
            ),
          ],
        ),
        const SizedBox(
          height: 8.0,
        ),
        LinearPercentIndicator(
          lineHeight: 12.0,
          percent: percent,
          backgroundColor: Colors.grey[200],
          progressColor: myThemeData.accentColor,
        ),
      ],
    );
  }
}

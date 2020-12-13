import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:web/ui/theme/theme.dart';

class UsageIndicator extends StatelessWidget {
  final String limit;
  final String usage;
  final double percent;
  const UsageIndicator({@required this.limit, @required this.usage, Key key, this.percent})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
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
        SizedBox(
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

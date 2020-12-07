import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:web/ui/theme/theme.dart';

class UsageIndicator extends StatelessWidget {
  final String limit;
  final String usage;
  const UsageIndicator({@required this.limit, @required this.usage, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //
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
        //space
        SizedBox(
          height: 8.0,
        ),
        //progress bar
        LinearPercentIndicator(
          // width: dou,
          lineHeight: 12.0,
          percent: calculateDataPercentage(),
          backgroundColor: Colors.grey[200],
          progressColor: myThemeData.accentColor,
        ),
      ],
    );
  }

  calculateDataPercentage() {
    int index = usage.indexOf(' ');
    double usageInKB;
    double limitInKB;
    String usageType = usage.substring(index + 1);
    //usage to kb
    if (usageType == 'KB') {
      print('kb');
      usageInKB = double.parse(usage.substring(0, index));
    } else if (usageType == 'MB') {
      print('mb');
      usageInKB = double.parse(usage.substring(0, index)) * 1024;
    } else {
      print('gb');
      usageInKB = double.parse(usage.substring(0, index)) * 1024 * 1024;
    }
    //limit to kb
    index = limit.indexOf(' ');
    limitInKB = double.parse(limit.substring(0, index)) * 1024 * 1024;
    //covert to percentage
    double percent = usageInKB / limitInKB;
    print('percent: ' + percent.toString());
    return percent;
  }
}

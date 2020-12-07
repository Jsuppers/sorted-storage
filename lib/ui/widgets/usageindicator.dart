import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

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
              style: TextStyle(
                color: Colors.blue[800],
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              limit,
              style: TextStyle(
                color: Colors.black26,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        //space
        SizedBox(
          height: 8.0,
        ),
        //
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Used",
              style: TextStyle(
                color: Colors.lightBlue[400],
                fontSize: 15.0,
              ),
            ),
            Text(
              "Upgrade",
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 15.0,
              ),
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
          lineHeight: 14.0,
          percent: calculateDataPercentage(),
          backgroundColor: Colors.grey,
          progressColor: Colors.blue,
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

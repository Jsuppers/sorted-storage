import 'package:flutter/material.dart';

/// Policy page
class PolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const String file = 'assets/docs/privacy.txt';
    return FutureBuilder<String>(
        future: DefaultAssetBundle.of(context).loadString(file),
        builder: (BuildContext context, AsyncSnapshot<String> document) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
                child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: RichText(
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <TextSpan>[
                    TextSpan(
                      text: document.data,
                      style: TextStyle(
                          color: Colors.black.withOpacity(0.6),
                          fontSize: 14,
                          fontWeight: FontWeight.normal),
                    ),
                  ],
                ),
              ),
            )),
          );
        });
  }
}

import 'package:flutter/material.dart';

class TermsPage extends StatelessWidget {
  static const String route = '/terms-of-conditions';

  @override
  Widget build(BuildContext context) {
    TextStyle normal = TextStyle(
        color: Colors.black.withOpacity(0.6),
        fontSize: 12,
        fontWeight: FontWeight.normal);
    return FutureBuilder(
        future:
            DefaultAssetBundle.of(context).loadString('assets/docs/terms.txt'),
        builder: (context, document) {
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

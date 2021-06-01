// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/sharing/sharing_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';

// ignore: public_member_api_docs
class ShareButton extends StatefulWidget {
  // ignore: public_member_api_docs
  const ShareButton({Key? key, required this.shared}) : super(key: key);

  // ignore: public_member_api_docs
  final bool shared;

  @override
  _ShareButtonState createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  late bool loading;

  @override
  void initState() {
    super.initState();
    loading = false;
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? StaticLoadingLogo()
        : MaterialButton(
            minWidth: 100,
            onPressed: () async {
              setState(() {
                loading = true;
              });
              if (widget.shared) {
                BlocProvider.of<SharingBloc>(context).add(StopSharingEvent());
              } else {
                BlocProvider.of<SharingBloc>(context).add(StartSharingEvent());
              }
            },
            color: myThemeData.primaryColorDark,
            textColor: Colors.white,
            child: Text(
              widget.shared ? 'stop sharing' : 'share',
              style: myThemeData.textTheme.button,
            ),
          );
  }
}

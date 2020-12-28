
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_event.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';

// ignore: public_member_api_docs
class ShareButton extends StatefulWidget {
  // ignore: public_member_api_docs
  const ShareButton({Key key, this.shared, this.loading}) : super(key: key);

  // ignore: public_member_api_docs
  final bool shared;
  // ignore: public_member_api_docs
  final bool loading;

  @override
  _ShareButtonState createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  bool loading;

  @override
  void initState() {
    super.initState();
    loading = widget.loading;
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

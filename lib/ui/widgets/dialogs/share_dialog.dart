import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_bloc.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/share_widget.dart';

class ShareDialog extends StatelessWidget {
  final String commentsID;
  final String folderID;

  const ShareDialog({Key key, this.commentsID, this.folderID})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (BuildContext context) => SharingBloc(
            BlocProvider.of<DriveBloc>(context).state, folderID, commentsID),
        child: Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          elevation: 1,
          child: BlocBuilder<SharingBloc, bool>(builder: (context, shared) {
            if (shared == null) {
              return FullPageLoadingLogo(backgroundColor: Colors.white);
            }
            return ShareWidget(folderID: folderID, shared: shared);
          }),
        ));
  }
}

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/drive/drive_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_bloc.dart';
import 'package:web/app/blocs/sharing/sharing_state.dart';
import 'package:web/app/services/google_drive.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/share_widget.dart';

/// dialog to share or stop sharing a story
class ShareDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const ShareDialog({Key? key, this.commentsID, required this.folderID})
      : super(key: key);

  // ignore: public_member_api_docs
  final String? commentsID;

  // ignore: public_member_api_docs
  final String folderID;

  @override
  Widget build(BuildContext context) {
    final GoogleDrive storage =
        GoogleDrive(driveApi: BlocProvider.of<DriveBloc>(context).state);
    return BlocProvider<SharingBloc>(
      create: (BuildContext context) =>
          SharingBloc(folderID, commentsID, storage),
      child: Dialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0))),
        elevation: 1,
        child: BlocBuilder<SharingBloc, SharingState?>(
          builder: (BuildContext context, SharingState? state) {
            if (state == null) {
              return const FullPageLoadingLogo(backgroundColor: Colors.white);
            }
            return ShareWidget(
                key: Key(DateTime.now().toString()),
                folderID: folderID,
                state: state);
          },
        ),
      ),
    );
  }
}

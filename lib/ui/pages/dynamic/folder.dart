// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_builder/responsive_builder.dart';

// Project imports:
import 'package:web/app/blocs/folder_storage/folder_storage_bloc.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_event.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_state.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_type.dart';
import 'package:web/app/extensions/metadata.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/ui/layouts/timeline/timeline_card.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';

/// page which shows a single folder
class FolderPage extends StatefulWidget {
  // ignore: public_member_api_docs
  const FolderPage(this._destination);

  final String _destination;

  @override
  _ViewPageState createState() => _ViewPageState();
}

class _ViewPageState extends State<FolderPage> {
  Folder? folder;
  bool error = false;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<FolderStorageBloc>(context).add(FolderStorageEvent(
        FolderStorageType.getFolder,
        folderID: widget._destination));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FolderStorageBloc, FolderStorageState?>(
      listener: (BuildContext context, FolderStorageState? state) {
        if (state == null) {
          return;
        }
        if (state.type == FolderStorageType.getFolder &&
            state.folderID == widget._destination) {
          setState(() {
            folder = state.data as Folder;
          });
        }
      },
      child: folder == null
          ? const FullPageLoadingLogo(backgroundColor: Colors.transparent)
          : ResponsiveBuilder(
              builder: (BuildContext context, SizingInformation info) {
                return error
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const SizedBox(height: 20),
                          Text(
                            'Error getting content',
                            style: myThemeData.textTheme.headline3,
                          ),
                          Text(
                            'are you sure the link is correct?',
                            style: myThemeData.textTheme.bodyText1,
                          ),
                          Image.asset('assets/images/error.png'),
                        ],
                      )
                    : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: getLayout(
                          info.screenSize.width,
                          info.screenSize.height,
                        ));
              },
            ),
    );
  }

  Widget getLayout(double width, double height) {
    final FolderLayout? type = folder!.metadata.getLayout();
    if (type == null || type == FolderLayout.basic) {
      return TimelineCard(
        folder: folder!,
        width: width,
        height: height,
      );
    }
    return Container();
  }
}

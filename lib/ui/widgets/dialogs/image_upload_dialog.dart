import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_state.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/media_progress.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/ui/helpers/text_display.dart';

/// image upload dialog
class ImageUploadDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const ImageUploadDialog({Key key, this.folderID, this.parentID, this.file})
      : super(key: key);

  // ignore: public_member_api_docs
  final String folderID;

  // ignore: public_member_api_docs
  final String parentID;

  final FilePickerResult file;

  @override
  Widget build(BuildContext context) {
    final Map<String, StoryMedia> images = <String, StoryMedia>{};
    for (int i = 0; i < file.files.length; i++) {
      final PlatformFile element = file.files[i];
      final String mime = lookupMimeType(element.name);

      final StoryMedia media = StoryMedia(
          name: element.name,
          stream: element.readStream,
          contentSize: element.size,
          isVideo: mime.startsWith('video/'),
          isDocument: !mime.startsWith('video/') && !mime.startsWith('image/'));
      images.putIfAbsent(element.name, () => media);
    }
    BlocProvider.of<EditorBloc>(context).add(EditorEvent(
        EditorType.uploadImages,
        parentID: parentID,
        folderID: folderID,
        data: images));

    return Dialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4.0))),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ResponsiveBuilder(
          builder: (BuildContext context, SizingInformation constraints) {
            return Column(
              children: <Widget>[
                SizedBox(
                  height: constraints.localWidgetSize.height - 50,
                  width: constraints.localWidgetSize.width,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        for (int i = 0; i < images.keys.length; i++)
                          ImageUpload(
                            name: images.keys.elementAt(i),
                            index: i,
                          )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      MaterialButton(
                          minWidth: 100,
                          color: Colors.white,
                          textColor: Colors.black,
                          onPressed: () =>
                              BlocProvider.of<NavigationBloc>(context)
                                  .add(NavigatorPopEvent()),
                          child: Row(
                            children: const <Widget>[
                              Icon(
                                Icons.cancel,
                                color: Colors.black,
                              ),
                              SizedBox(width: 5),
                              Text('cancel'),
                            ],
                          )),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class ImageUpload extends StatefulWidget {
  ImageUpload({Key key, this.name, this.index}) : super(key: key);

  String name;
  int index;

  @override
  _ImageUploadState createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  double percent;
  bool error;

  @override
  void initState() {
    super.initState();
    percent = 0;
  }

  @override
  Widget build(BuildContext context) {
    Color progressColor;
    if (error == true) {
      progressColor = Colors.red;
    } else if (percent == 0) {
      progressColor = Colors.grey;
    } else if (percent < 1) {
      progressColor = Colors.orangeAccent;
    } else {
      progressColor = Colors.green;
    }

    return BlocListener<EditorBloc, EditorState>(
      listener: (BuildContext context, EditorState state) {
        if (state.type == EditorType.uploadStatus) {
          final MediaProgress progress = state.data as MediaProgress;
          if (progress.index == widget.index) {
            if (state.error != null) {
              setState(() {
                error = true;
                percent = 0;
              });
            } else {
              setState(() {
                percent = progress.sent / progress.total;
              });
            }
          }
        }
      },
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              TextDisplay.shortenFilename(widget.name),
              style: TextStyle(
                fontSize: 16.0,
                color: progressColor,
              ),
            ),
            const SizedBox(width: 20),
            if (error == true)
              Icon(Icons.error_outline, color: progressColor, size: 16)
            else
              percent == 1
                  ? Icon(Icons.check, color: progressColor, size: 16)
                  : CircularPercentIndicator(
                      radius: 28.0,
                      percent: percent,
                      center: IconButton(
                          icon:
                              Icon(Icons.close, color: progressColor, size: 12),
                          onPressed: () => {
                                BlocProvider.of<EditorBloc>(context).add(
                                    EditorEvent(EditorType.ignoreImage,
                                        data: widget.index))
                              }),
                      circularStrokeCap: CircularStrokeCap.round,
                      progressColor: progressColor,
                      backgroundColor: Colors.grey[200],
                    ),
          ]),
    );
  }
}

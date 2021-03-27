import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/navigation/navigation_bloc.dart';
import 'package:web/app/blocs/navigation/navigation_event.dart';
import 'package:web/app/models/story_media.dart';

/// image upload dialog
class ImageUploadDialog extends StatelessWidget {
  // ignore: public_member_api_docs
  const ImageUploadDialog({Key key, this.folderID, this.parentID})
      : super(key: key);

  // ignore: public_member_api_docs
  final String folderID;

  // ignore: public_member_api_docs
  final String parentID;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<FilePickerResult>(
        future: FilePicker.platform.pickFiles(
            type: FileType.media, allowMultiple: true, withReadStream: true),
        builder: (BuildContext context, AsyncSnapshot<FilePickerResult> file) {
          if (file.data == null ||
              file.data.files == null ||
              file.data.files.isEmpty) {
            return Container();
          }
          Map<String, StoryMedia> images = {};
          for (int i = 0; i < file.data.files.length; i++) {
            final PlatformFile element = file.data.files[i];
            final String mime = lookupMimeType(element.name);

            final StoryMedia media = StoryMedia(
                stream: element.readStream,
                contentSize: element.size,
                isVideo: mime.startsWith('video/'),
                isDocument: !mime.startsWith('video/') &&
                    !mime.startsWith('image/'));
            images.putIfAbsent(
                element.name,
                () => media);
          }
          BlocProvider.of<EditorBloc>(context).add(
              EditorEvent(EditorType.uploadImages, parentID: parentID, folderID: folderID, data: images));

          return Dialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ResponsiveBuilder(
                builder: (BuildContext context, SizingInformation constraints) {
                  return Column(
                    children: [
                      Container(
                        height: constraints.localWidgetSize.height - 50,
                        width: constraints.localWidgetSize.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical, //.horizontal
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
        });
  }
}

class ImageUpload extends StatelessWidget {
  ImageUpload({Key key, this.name, this.index}) : super(key: key);

  String name;
  int index;

  @override
  Widget build(BuildContext context) {
    
    double percent = 0;
    
    Color progressColor;
    if (percent == 0) {
      progressColor = Colors.grey;
    } else if (percent < 1) {
      progressColor = Colors.orangeAccent;
    } else {
      progressColor = Colors.green;
    }

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            name,
            style: new TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          SizedBox(width: 20),
          percent == 1
              ? Icon(Icons.check, color: progressColor, size: 16)
              : CircularPercentIndicator(
                  radius: 28.0,
                  lineWidth: 5.0,
                  percent: percent,
                  center: IconButton(
                      icon: Icon(Icons.close, color: progressColor, size: 12),
                      onPressed: () => {}),
                  circularStrokeCap: CircularStrokeCap.round,
                  progressColor: progressColor,
                  backgroundColor: Colors.grey[200],
                ),
        ]);
  }
}

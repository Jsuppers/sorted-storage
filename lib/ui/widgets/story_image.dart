import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/ui/widgets/loading.dart';

/// image in the story
class StoryImage extends StatefulWidget {
  // ignore: public_member_api_docs
  const StoryImage(
      {Key key,
        this.locked,
        this.uploadingImages,
        this.storyMedia,
        this.imageKey,
        this.storyFolderID,
        this.folderID})
      : super(key: key);

  // ignore: public_member_api_docs
  final bool locked;
  // ignore: public_member_api_docs
  final List<String> uploadingImages;
  // ignore: public_member_api_docs
  final StoryMedia storyMedia;
  // ignore: public_member_api_docs
  final String imageKey;
  // ignore: public_member_api_docs
  final String storyFolderID;
  // ignore: public_member_api_docs
  final String folderID;


  @override
  _StoryImageState createState() => _StoryImageState();
}

class _StoryImageState extends State<StoryImage> {
  @override
  Widget build(BuildContext context) {
    return imageWidget(widget.imageKey, widget.storyMedia);
  }

  Widget imageWidget(String imageKey, StoryMedia media) {
    final bool showPlaceholder = media.thumbnailURL == null;
    return RawMaterialButton(
      onPressed: () {
        if (widget.locked) {
          URLService.openDriveMedia(imageKey);
        }
      },
      child: showPlaceholder
          ? _backgroundImage(showPlaceholder, imageKey, media, null)
          : SizedBox(
              height: widget.locked == false ? 80 : 150.0,
              width: widget.locked == false ? 80 : 150.0,
              child: CachedNetworkImage(
                imageUrl: media.thumbnailURL,
                placeholder: (BuildContext context, String url) =>
                    StaticLoadingLogo(),
                errorWidget:
                    (BuildContext context, String url, dynamic error) =>
                        _backgroundImage(showPlaceholder, imageKey, media,
                            const AssetImage('assets/images/error.png')),
                imageBuilder: (BuildContext context,
                        ImageProvider<Object> image) =>
                    _backgroundImage(showPlaceholder, imageKey, media, image),
              ),
            ),
    );
  }

  Widget _backgroundImage(bool showPlaceholder, String imageKey,
      StoryMedia media, ImageProvider image) {
    return Container(
      height: 150.0,
      width: 150.0,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        image: showPlaceholder
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      child: !widget.locked
          ? _createEditControls(imageKey, showPlaceholder)
          : _createNonEditControls(imageKey, showPlaceholder, media),
    );
  }

  Widget _createNonEditControls(
      String imageKey, bool showPlaceholder, StoryMedia media) {
    if (showPlaceholder) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(Icons.insert_drive_file),
          Center(child: Text(imageKey)),
        ],
      );
    }
    if (!media.isVideo && !media.isDocument) {
      return Container();
    }
    return Align(
      child: Padding(
        padding: const EdgeInsets.only(right: 3, top: 3),
        child: Container(
          height: 34,
          width: 34,
          decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(40))),
          child: Icon(
            media.isVideo ? Icons.play_arrow : Icons.insert_drive_file,
            color: Colors.black,
            size: 18,
          ),
        ),
      ),
    );
  }

  Widget _createEditControls(String imageKey, bool showPlaceholder) {
    return Container(
      color: widget.uploadingImages.contains(imageKey)
          ? Colors.white.withOpacity(0.5)
          : null,
      child: Column(
        children: <Widget>[
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 3, top: 3),
                child: Container(
                  height: 34,
                  width: 34,
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.all(Radius.circular(40))),
                  child: IconButton(
                    iconSize: 18,
                    splashRadius: 18,
                    icon: Icon(Icons.clear,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    onPressed: () {
                      BlocProvider.of<EditorBloc>(context).add(
                          EditorEvent(EditorType.deleteImage,
                              folderID: widget.folderID,
                              data: imageKey,
                              parentID: widget.storyFolderID));

                    },
                  ),
                ),
              )),
          Column(children: <Widget>[
            if (widget.uploadingImages.contains(imageKey))
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: StaticLoadingLogo(),
              )
            else
              Container(),
            if (showPlaceholder)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.insert_drive_file),
                  Center(child: Text(imageKey)),
                ],
              )
            else
              Container()
          ])
        ],
      ),
    );
  }
}

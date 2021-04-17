import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:web/app/blocs/cloud_stories/cloud_stories_bloc.dart';
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/models/story_media.dart';
import 'package:web/app/services/retry_service.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/media_card.dart';

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
    return RetryMediaWidget(
      folderId: widget.folderID,
      locked: widget.locked,
      media: widget.storyMedia,
      storyFolderID: widget.storyFolderID,
    );
  }
}

class RetryMediaWidget extends StatefulWidget {
  RetryMediaWidget({this.folderId, this.locked, this.media, this.storyFolderID})
      : super();

  @override
  _RetryMediaWidgetState createState() => _RetryMediaWidgetState();

  String folderId;
  StoryMedia media;
  bool locked;
  String storyFolderID;
}

class _RetryMediaWidgetState extends State<RetryMediaWidget> {
  bool showPlaceholder;

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
          ? _createEditControls(
          widget.media.fileID,
          widget.media.name,
          showPlaceholder)
          : _createNonEditControls(widget.media.fileID, showPlaceholder, media),
    );
  }

  Widget _createNonEditControls(
      String imageKey, bool showPlaceholder, StoryMedia media) {
    if (showPlaceholder) {
      return MediaCard(media);
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

  Widget _createEditControls(String imageKey, String imagename, bool showPlaceholder) {
    return Container(
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
                    icon: const Icon(
                      Icons.clear,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    onPressed: () {
                      BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                          EditorType.deleteImage,
                          folderID: widget.folderId,
                          data: imageKey,
                          parentID: widget.storyFolderID));
                    },
                  ),
                ),
              )),
          Column(children: <Widget>[
            if (showPlaceholder)
              MediaCard(widget.media)
            else
              Container()
          ])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
        future: RetryService.getThumbnail(
          BlocProvider.of<CloudStoriesBloc>(context).storage,
          widget.media.thumbnailURL,
          widget.folderId,
          widget.media.fileID,
          retrieveThumbnail: widget.media.retrieveThumbnail,
        ),
        builder: (BuildContext context, AsyncSnapshot<String> thumbnailURL) {
          showPlaceholder = thumbnailURL.data == null;
          return RawMaterialButton(
            onPressed: () {
              if (widget.locked) {
                URLService.openDriveMedia(widget.media.fileID);
              }
            },
            child: showPlaceholder
                ? _backgroundImage(
                    showPlaceholder, widget.media.fileID, widget.media, null)
                : SizedBox(
                    height: widget.locked == false ? 80 : 150.0,
                    width: widget.locked == false ? 80 : 150.0,
                    child: thumbnailURL.data == null
                        ? StaticLoadingLogo()
                        : CachedNetworkImage(
                            imageUrl: thumbnailURL.data,
                            placeholder: (BuildContext context, String url) =>
                                StaticLoadingLogo(),
                            errorWidget: (BuildContext context, String url,
                                    dynamic error) =>
                                _backgroundImage(
                                    showPlaceholder,
                                    widget.media.fileID,
                                    widget.media,
                                    const AssetImage(
                                        'assets/images/error.png')),
                            imageBuilder: (BuildContext context,
                                    ImageProvider<Object> image) =>
                                _backgroundImage(showPlaceholder,
                                    widget.media.fileID, widget.media, image),
                          ),
                  ),
          );
        });
  }
}

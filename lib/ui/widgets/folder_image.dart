// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:web/app/blocs/editor/editor_bloc.dart';
import 'package:web/app/blocs/editor/editor_event.dart';
import 'package:web/app/blocs/editor/editor_type.dart';
import 'package:web/app/blocs/folder_storage/folder_storage_bloc.dart';
import 'package:web/app/models/folder.dart';
import 'package:web/app/models/folder_media.dart';
import 'package:web/app/services/retry_service.dart';
import 'package:web/app/services/url_service.dart';
import 'package:web/ui/theme/theme.dart';
import 'package:web/ui/widgets/loading.dart';
import 'package:web/ui/widgets/media_card.dart';

/// image in the folder
class FolderImage extends StatefulWidget {
  // ignore: public_member_api_docs
  const FolderImage({
    Key? key,
    required this.locked,
    required this.folderMedia,
    required this.imageKey,
    required this.folder,
  }) : super(key: key);

  // ignore: public_member_api_docs
  final bool locked;

  // ignore: public_member_api_docs
  final FolderMedia folderMedia;

  // ignore: public_member_api_docs
  final String imageKey;

  // ignore: public_member_api_docs
  final Folder folder;

  @override
  _FolderImageState createState() => _FolderImageState();
}

class _FolderImageState extends State<FolderImage> {
  @override
  Widget build(BuildContext context) {
    return RetryMediaWidget(
      folder: widget.folder,
      locked: widget.locked,
      media: widget.folderMedia,
    );
  }
}

class RetryMediaWidget extends StatefulWidget {
  RetryMediaWidget(
      {required this.folder, required this.locked, required this.media})
      : super();

  @override
  _RetryMediaWidgetState createState() => _RetryMediaWidgetState();

  Folder folder;
  FolderMedia media;
  bool locked;
}

class _RetryMediaWidgetState extends State<RetryMediaWidget> {
  bool showPlaceholder = false;

  Widget _backgroundImage(
      String imageKey, FolderMedia media, ImageProvider? image,
      {bool error = false}) {
    return Container(
      height: 150.0,
      width: 150.0,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(6)),
        image: image == null
            ? null
            : DecorationImage(image: image, fit: BoxFit.cover),
      ),
      child: !widget.locked
          ? _createEditControls(
              widget.media.id, widget.media.name, showPlaceholder)
          : _createNonEditControls(widget.media.id, showPlaceholder, media),
    );
  }

  Widget _createNonEditControls(
      String imageKey, bool showPlaceholder, FolderMedia media) {
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

  Widget _createEditControls(
      String imageKey, String imagename, bool showPlaceholder) {
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
                      UpdateDeleteImageEvent update = UpdateDeleteImageEvent(
                        imageID: imageKey,
                        folder: widget.folder,
                      );
                      BlocProvider.of<EditorBloc>(context).add(EditorEvent(
                          EditorType.deleteImage,
                          refreshUI: true,
                          data: update));
                    },
                  ),
                ),
              )),
          Column(children: <Widget>[
            if (showPlaceholder) MediaCard(widget.media) else Container()
          ])
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
        future: RetryService.getThumbnail(
          BlocProvider.of<FolderStorageBloc>(context).storage,
          widget.media.thumbnailURL,
          widget.folder.id!,
          widget.media.id,
          retrieveThumbnail: widget.media.retrieveThumbnail,
        ),
        builder: (BuildContext context, AsyncSnapshot<String?> thumbnailURL) {
          if (thumbnailURL.data != null) {
            widget.media.thumbnailURL = thumbnailURL.data;
          }
          showPlaceholder = thumbnailURL.data == null;
          return RawMaterialButton(
            onPressed: () {
              if (widget.locked) {
                URLService.openDriveMedia(widget.media.id);
              }
            },
            child: showPlaceholder
                ? _backgroundImage(widget.media.id, widget.media, null)
                : SizedBox(
                    height: widget.locked == false ? 180 : 250.0,
                    width: widget.locked == false ? 80 : 150.0,
                    child: thumbnailURL.data == null
                        ? StaticLoadingLogo()
                        : Column(
                            children: [
                              SizedBox(
                                height: widget.locked == false ? 80 : 150.0,
                                width: widget.locked == false ? 80 : 150.0,
                                child: CachedNetworkImage(
                                  imageUrl: thumbnailURL.data!,
                                  placeholder:
                                      (BuildContext context, String url) =>
                                          StaticLoadingLogo(),
                                  errorWidget: (BuildContext context,
                                          String url, dynamic error) =>
                                      _backgroundImage(
                                          widget.media.id,
                                          widget.media,
                                          const AssetImage(
                                              'assets/images/error.png')),
                                  imageBuilder: (BuildContext context,
                                          ImageProvider<Object> image) =>
                                      _backgroundImage(
                                          widget.media.id, widget.media, image),
                                ),
                              ),
                              ImageDescription(
                                media: widget.media,
                                folder: widget.folder,
                              )
                            ],
                          ),
                  ),
          );
        });
  }
}

class ImageDescription extends StatefulWidget {
  ImageDescription({required this.media, required this.folder});
  FolderMedia media;
  Folder folder;

  @override
  _ImageDescriptionState createState() => _ImageDescriptionState();
}

class _ImageDescriptionState extends State<ImageDescription> {
  TextEditingController descriptionController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    descriptionController.text = widget.media.getDescription() ?? '';
    descriptionController.selection =
        TextSelection.collapsed(offset: descriptionController.text.length);

    return TextFormField(
        controller: descriptionController,
        style: TextStyle(
            fontSize: 14.0,
            fontFamily: 'OpenSans',
            color: myThemeData.primaryColorDark),
        decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: 'Enter a description'),
        onChanged: (String content) {
          if (_debounce?.isActive ?? false) _debounce?.cancel();
          _debounce = Timer(const Duration(milliseconds: 500), () {
            widget.media.setDescription(content);
            UpdateImageMetaDataEvent update = UpdateImageMetaDataEvent(
                folder: widget.folder, media: widget.media);
            BlocProvider.of<EditorBloc>(context)
                .add(EditorEvent(EditorType.updateImageMetadata, data: update));
          });
        },
        maxLines: null);
  }
}

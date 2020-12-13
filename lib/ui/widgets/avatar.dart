import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class Avatar extends StatefulWidget {
  final String url;
  final double size;

  Avatar({this.url, this.size});

  @override
  State<StatefulWidget> createState() => new _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      width: widget.size,
      height: widget.size,
      decoration: new BoxDecoration(
        color: Color(0xFFdedee0),
        shape: BoxShape.circle,
      ),
      child: new ClipOval(
          child: CachedNetworkImage(
        imageUrl: widget.url,
        progressIndicatorBuilder: (context, url, downloadProgress) =>
            CircularProgressIndicator(value: downloadProgress.progress),
        errorWidget: (context, url, error) =>
            Image.asset("assets/images/error.png"),
      )),
    );
  }
}

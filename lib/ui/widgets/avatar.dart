// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cached_network_image/cached_network_image.dart';

/// avatar of the user
class Avatar extends StatefulWidget {
  // ignore: public_member_api_docs
  const Avatar({required this.url, required this.size});

  // ignore: public_member_api_docs
  final String url;

  // ignore: public_member_api_docs
  final double size;

  @override
  State<StatefulWidget> createState() => _AvatarState();
}

class _AvatarState extends State<Avatar> {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: widget.size,
      child: ClipOval(
          child: CachedNetworkImage(
        imageUrl: widget.url,
        progressIndicatorBuilder: (BuildContext context, String url, _) =>
            const CircularProgressIndicator(),
        errorWidget: (BuildContext context, String url, dynamic error) =>
            Image.asset('assets/images/error.png'),
      )),
    );
  }
}

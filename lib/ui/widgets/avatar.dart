import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// avatar of the user
class Avatar extends StatefulWidget {
  // ignore: public_member_api_docs
  const Avatar({this.url, this.size});

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
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: const BoxDecoration(
        color: Color(0xFFdedee0),
        shape: BoxShape.circle,
      ),
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

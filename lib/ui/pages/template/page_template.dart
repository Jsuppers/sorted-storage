import 'package:flutter/material.dart';
import 'package:web/app/models/page_content.dart';

/// template for displaying a page
class PageTemplate extends StatelessWidget {
  // ignore: public_member_api_docs
  const PageTemplate(this._contentList);

  final List<PageItemContent> _contentList;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return Column(
          children: _createContent(constraints),
        );
      },
    );
  }

  List<Widget> _createContent(BoxConstraints constraints) {
    bool borderless = true;
    bool mobile = false;
    final double width = constraints.biggest.width;
    const double padding = 40.0;
    double contentWidth = (constraints.biggest.width) / 2 - padding;

    if (constraints.maxWidth <= 800) {
      contentWidth = width - padding * 2;
      mobile = true;
    }

    final List<Widget> children = <Widget>[];
    for (final PageItemContent content in _contentList) {
      if (borderless) {
        children.add(
          _BorderlessContent(
            mobile: mobile,
            width: width,
            horizontalPadding: padding,
            widthImage: contentWidth,
            widthText: contentWidth,
            content: content,
          ),
        );
      } else {
        children.add(
          _BorderedContent(
            mobile: mobile,
            width: width,
            horizontalPadding: padding,
            widthImage: contentWidth,
            widthText: contentWidth,
            content: content,
          ),
        );
      }
      borderless = !borderless;
    }
    return children;
  }
}

class _BorderlessContent extends StatelessWidget {
  const _BorderlessContent(
      {Key? key,
      required this.width,
      required this.content,
      required this.widthText,
      required this.widthImage,
      required this.horizontalPadding,
      required this.mobile})
      : super(key: key);

  final double width;
  final double widthText;
  final double widthImage;
  final double horizontalPadding;
  final PageItemContent content;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    if (content.imageURL == null) {
      children
          .add(_TextWidget(width: widthText + widthImage, content: content));
    } else {
      children.addAll(<Widget>[
        _TextWidget(width: widthText, content: content),
        _ImageWidget(imageUri: content.imageURL, width: widthImage)
      ]);
    }

    return Padding(
      padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding, vertical: horizontalPadding / 2),
      child: mobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start, children: children)
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start, children: children),
    );
  }
}

class _BorderedContent extends StatelessWidget {
  const _BorderedContent(
      {required this.width,
      required this.content,
      required this.widthText,
      required this.widthImage,
      required this.horizontalPadding,
      required this.mobile});

  final double width;
  final double widthText;
  final double widthImage;
  final double horizontalPadding;
  final PageItemContent content;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = <Widget>[];

    if (content.imageURL == null) {
      children.add(
        _TextWidget(width: widthText + widthImage, content: content),
      );
    } else {
      children.addAll(<Widget>[
        _ImageWidget(imageUri: content.imageURL, width: widthImage),
        _TextWidget(width: widthText, content: content)
      ]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 200),
            child: Container(
              width: width,
              color: Colors.white,
              child: mobile
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: children),
            ),
          ),
        ),
      ),
    );
  }
}

class _CallToActionButton extends StatelessWidget {
  const _CallToActionButton({
    Key? key,
    required this.content,
  }) : super(key: key);

  final PageItemContent content;

  @override
  Widget build(BuildContext context) {
    if (content.callToActionButtonText == null) {
      return Container();
    }

    return MaterialButton(
      onPressed: () {
        if (content.callToActionCallback != null) {
          content.callToActionCallback!();
        }
      },
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
        child: Text(
          content.callToActionButtonText!,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
    );
  }
}

class _TextWidget extends StatelessWidget {
  const _TextWidget({Key? key, required this.width, required this.content})
      : super(key: key);
  final double width;
  final PageItemContent content;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const SizedBox(height: 20),
            Text(content.title, style: Theme.of(context).textTheme.headline1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                content.text,
                textAlign: TextAlign.justify,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
            _CallToActionButton(content: content)
          ],
        ),
      ),
    );
  }
}

class _ImageWidget extends StatelessWidget {
  const _ImageWidget({Key? key,
    required this.imageUri,
    required this.width}) : super(key: key);
  final String imageUri;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8.0)),
              child: Image.asset(
                imageUri,
              ),
            ),
          ),
          Container(),
        ],
      ),
    );
  }
}

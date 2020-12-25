import 'package:flutter/material.dart';
import 'package:web/app/models/page_content.dart';

class PageTemplate extends StatelessWidget {
  final List<PageItemContent> contentList;

  PageTemplate(this.contentList);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            ...createContent(constraints),
          ],
        );
      },
    );
  }

  List<Widget> createContent(BoxConstraints constraints) {
    bool borderless = true;
    bool mobile = false;
    double width = constraints.biggest.width;
    double padding = 40.0;
    double contentWidth = (constraints.biggest.width) / 2 - padding;

    if (constraints.maxWidth <= 800) {
      contentWidth = width - padding * 2;
      mobile = true;
    }

    List<Widget> children = [];
    for (PageItemContent content in contentList) {
      if (borderless) {
        children.add(_BorderlessContent(
          mobile: mobile,
          width: width,
          horizontalPadding: padding,
          widthImage: contentWidth,
          widthText: contentWidth,
          content: content,
        ));
      } else {
        children.add(_BorderedContent(
          mobile: mobile,
          width: width,
          horizontalPadding: padding,
          widthImage: contentWidth,
          widthText: contentWidth,
          content: content,
        ));
      }
      borderless = !borderless;
    }
    return children;
  }
}

class _BorderlessContent extends StatelessWidget {
  final double width;
  final double widthText;
  final double widthImage;
  final double horizontalPadding;
  final PageItemContent content;
  final bool mobile;

  const _BorderlessContent(
      {Key key,
      this.width,
      this.content,
      this.widthText,
      this.widthImage,
      this.horizontalPadding,
      this.mobile})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> children;

    if (content.imageURL == null) {
      children = [
        _TextWidget(width: widthText + widthImage, content: content),
      ];
    } else {
      children = [
        _TextWidget(width: widthText, content: content),
        _ImageWidget(imageUri: content.imageURL, width: widthImage)
      ];
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
  final double width;
  final double widthText;
  final double widthImage;
  final double horizontalPadding;
  final PageItemContent content;
  final bool mobile;

  const _BorderedContent(
      {this.width,
      this.content,
      this.widthText,
      this.widthImage,
      this.horizontalPadding,
      this.mobile});

  @override
  Widget build(BuildContext context) {
    List<Widget> children;

    if (content.imageURL == null) {
      children = [
        _TextWidget(width: widthText + widthImage, content: content),
      ];
    } else {
      children = [
        _ImageWidget(imageUri: content.imageURL, width: widthImage),
        _TextWidget(width: widthText, content: content)
      ];
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: 200),
            child: Container(
              width: width,
              color: Colors.white,
              child: mobile
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: children)
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
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
    Key key,
    @required this.content,
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
          content.callToActionCallback();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
        child: Text(
          content.callToActionButtonText,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      color: Colors.white,
    );
  }
}

class _TextWidget extends StatelessWidget {
  final double width;
  final PageItemContent content;

  const _TextWidget({Key key, this.width, this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
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
  final String imageUri;
  final double width;

  const _ImageWidget({Key key, this.imageUri, this.width}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(),
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: width),
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
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

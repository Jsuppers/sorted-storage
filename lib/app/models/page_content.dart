/// A item in a page which shows text and an image
class PageItemContent {
  // ignore: public_member_api_docs
  PageItemContent(
      {this.title,
      this.text,
      this.imageURL,
      this.callToActionButtonText,
      this.callToActionCallback});

  /// title of the item
  String title;

  /// text shown
  String text;

  /// URL for the image
  String imageURL;

  /// text for the call to action button
  String callToActionButtonText;

  /// function which is called when the user clicks the call to action button
  Function callToActionCallback;
}

/// progress of media being sent
class MediaProgress {
  // ignore: public_member_api_docs
  MediaProgress(this.total, this.sent);

  /// total amount of bytes
  final int total;

  /// amount of bytes sent
  final int sent;
}

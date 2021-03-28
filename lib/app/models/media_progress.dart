/// progress of media being sent
class MediaProgress {
  // ignore: public_member_api_docs
  MediaProgress(this.index, this.total, this.sent);

  /// index
  final int index;

  /// total amount of bytes
  final int total;

  /// amount of bytes sent
  final int sent;
}

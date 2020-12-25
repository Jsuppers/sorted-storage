/// information to show current cloud storage usage and limit
class StorageInformation {
  // ignore: public_member_api_docs
  StorageInformation({this.percent, this.usage, this.limit});

  /// used space
  final String usage;

  /// maximum space in cloud storage
  final String limit;

  /// percentage used
  final double percent;
}

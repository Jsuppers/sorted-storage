extension StringExtension on String {
  String ellipseOverflow(int maxSize) {
    if (length <= maxSize) {
      return this;
    }
    return '${substring(0, maxSize)}...';
  }
}

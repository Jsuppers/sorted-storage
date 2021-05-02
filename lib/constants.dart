/// Constant files which holds various constants
class Constants {
  static const String originalValueKey = 'originalRoute';

  /// url of sorted storage website
  static const String websiteURL = 'https://sortedstorage.com/#';

  /// the root folder for sorted storage
  static const String rootFolder = 'sorted-storage';

  /// file name of settings file
  static const String settingsFile = 'settings.json';

  /// donate url
  static const String donateURL = 'https://www.buymeacoffee.com/joris';

  /// github page url
  static const String githubURL = 'https://github.com/Jsuppers/sorted-storage';

  /// profile url
  static const String profileURL = 'https://myaccount.google.com/personal-info';

  /// url to upgrade the storage plan
  static const String upgradeURL = 'https://one.google.com/about/plans';

  /// shared preferences variable used to indicate if the cookie message
  /// has been accepted
  static const String acceptedCookieVariable = 'ACCEPTED_COOKIE';

  /// minimum width of a screen
  static const double minScreenWidth = 600;

  /// maximum size of a filename (for the ui so it doesn't overflow)
  static const int maxFileName = 30;
}

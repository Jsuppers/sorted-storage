import 'package:envify/envify.dart';
part 'env.g.dart';

/// Env class holds all environment variables
@Envify()
abstract class Env {
  /// Google api key to allow for communication with the Google API for
  /// unauthenticated users
  static const String googleApiKey = _Env.googleApiKey;
}

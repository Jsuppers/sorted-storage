import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http_retry/http_retry.dart';
import 'package:web/env/env.dart';

/// http client with headers
class ClientWithAuthHeaders extends http.BaseClient {
  /// constructor which sets a retry client with headers
  ClientWithAuthHeaders(Map<String, String> headers) {
    _client = RetryClient(http.Client(),
        when: (http.BaseResponse r) => r.statusCode >= 400);
    _headers = headers;
  }

  Map<String, String> _headers;
  http.Client _client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    request.headers.remove('content-length');
    request.headers.remove('user-agent');

    final http.BaseRequest baseRequest = request..headers.addAll(_headers);
    return _client.send(baseRequest);
  }
}

/// http client with a google api key as query parameter
class ClientWithGoogleDriveKey extends http.BaseClient {
  /// set a retry http client
  ClientWithGoogleDriveKey() {
    _client = RetryClient(http.Client(),
        when: (http.BaseResponse r) => r.statusCode >= 400, retries: 5);
  }

  http.Client _client;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.remove('content-length');
    request.headers.remove('user-agent');

    final Map<String, String> newParameters =
        Map<String, String>.from(request.url.queryParameters);
    newParameters.putIfAbsent('key', () => Env.googleApiKey);
    final Uri uri = request.url.replace(queryParameters: newParameters);
    final http.BaseRequest baseRequest = http.Request(request.method, uri);
    baseRequest.headers.addAll(request.headers);

    return _client.send(baseRequest);
  }
}

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/app/blocs/cookie_notice/cookie_notice_event.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';

///
class CookieNoticeBloc extends Cubit<CookieNoticeEvent?> {

  ///
  CookieNoticeBloc() : super(null) {
    showing = false;
    sharedPreferenceInstance = SharedPreferences.getInstance();
  }

  /// is the notice showing or not
  late bool showing;

  /// local storage to store if the cookie notice has already been accepted
  late Future<SharedPreferences> sharedPreferenceInstance;

  /// show the cookie notice if needed
  Future<void> showCookie(BuildContext context) async {
    if (showing) {
      return;
    }
    showing = true;
    final SharedPreferences pref = await sharedPreferenceInstance;
    if (!pref.containsKey(Constants.acceptedCookieVariable)) {
      DialogService.cookieDialog(context);
    }
  }

  /// Accept the cookie notice and save the result to local storage
  Future<void> acceptCookie() async {
    final SharedPreferences pref = await sharedPreferenceInstance;
    pref.setBool(Constants.acceptedCookieVariable, true);
  }

}

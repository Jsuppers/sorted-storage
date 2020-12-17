import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/app/blocs/cookie_notice/cookie_notice_event.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';

class CookieNoticeBloc extends Cubit<CookieNoticeEvent> {
  bool showing;
  Future<SharedPreferences> sharedPreferenceInstance;

  CookieNoticeBloc() : super(null) {
    showing = false;
    sharedPreferenceInstance = SharedPreferences.getInstance();
  }

  Future showCookie(BuildContext context) async {
    if (showing) {
      return;
    }
    showing = true;
    var pref = await sharedPreferenceInstance;
    if (!pref.containsKey(Constants.ACCEPTED_COOKIE_VARIABLE)) {
      DialogService.cookieDialog(context);
    }
  }

  Future acceptCookie() async {
    var pref = await sharedPreferenceInstance;
    pref.setBool(Constants.ACCEPTED_COOKIE_VARIABLE, true);
  }

}

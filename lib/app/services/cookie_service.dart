import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web/app/services/dialog_service.dart';
import 'package:web/constants.dart';

class CookieService {
  static bool showing = false;
  static void showCookie(BuildContext context){
    if (showing) {
      return;
    }
    showing = true;
    SharedPreferences.getInstance().then((value) {
      if(!value.containsKey(Constants.ACCEPTED_COOKIE_VARIABLE)) {
        DialogService.cookieDialog(context);
      }
    });
  }

  static void acceptCookie(){
    SharedPreferences.getInstance().then((value) {
      value.setBool(Constants.ACCEPTED_COOKIE_VARIABLE, true);
    });
  }
}
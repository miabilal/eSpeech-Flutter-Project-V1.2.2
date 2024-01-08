import 'package:espeech/helper/constant.dart';
import 'package:espeech/model/plans.dart';
import 'package:espeech/screens/auth/loginactivity.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager extends ChangeNotifier {
  static const String preferanceName = "espeechPref";
  static const String isUserLogin = "IsUserLoggedIn";
  static const String isIntorSet = "isIntroSet";

  static String keyId = 'id';
  static String keyFirstName = 'firstname';
  static String keyLastName = 'lastname';
  static String keyPhone = 'phone';
  static String keyEmail = 'email';
  static String keyActive = 'active';
  static String keyFcmId = 'fcm_id';
  static String keyToken = 'token';
  static String keyImage = 'image';
  static String keyActiveSubscription = 'activeSubscription';
  static String keyUpcomingSubscription = 'upcomingSubscription';
  static String keyLanguageData = 'languagelist';

  SharedPreferences prefs;
  BuildContext context;

  SessionManager({
    required this.prefs,
    required this.context,
  });

  //SessionManager(this.prefs);

  SessionManager setPrefs(SharedPreferences prefs, BuildContext context) {
    SessionManager sessionManager =
        SessionManager(prefs: prefs, context: context);
    return sessionManager;
  }

  String getData(String id) {
    return prefs.getString(id) ?? "";
  }

  void setData(String id, String val) {
    prefs.setString(id, val);
  }

  List<String> geList(String id) {
    return prefs.getStringList(id) ?? [];
  }

  void setList(String id, List<String> list) {
    prefs.setStringList(id, list);
    notifyListeners();
  }

  void setDoubleData(String key, double value) {
    prefs.setDouble(key, value);
    notifyListeners();
  }

  double getDoubleData(String key) {
    return prefs.getDouble(key) ?? 0;
  }

  void setBoolData(String key, bool value, bool isrefresh) {
    prefs.setBool(key, value);
    if (isrefresh) notifyListeners();
  }

  int getIntData(String key) {
    return prefs.getInt(key) ?? 0;
  }

  void setIntData(String key, int value) {
    prefs.setInt(key, value);
    notifyListeners();
  }

  bool getBoolData(String key) {
    return prefs.getBool(key) ?? false;
  }

  bool isUserLoggedIn() {
    if (prefs.getBool(isUserLogin) == null) {
      return false;
    } else {
      return prefs.getBool(isUserLogin) ?? false;
    }
  }

  void logoutUser(BuildContext context) {
    String langdata = prefs.getString(keyLanguageData)!;
    prefs.clear();
    prefs.setBool(isUserLogin, false);
    prefs.setString(keyLanguageData, langdata);
    prefs.setBool(isIntorSet, true);

    Constant.killPreviousPages(context, LoginActivity(from: "logout"));
  }

  void setUserDetail(Map data, String token) {
    prefs.setBool(isUserLogin, true);
    if (data.containsKey(Constant.id)) {
      setData(keyId, data[Constant.id].toString());
    }
    if (data.containsKey(Constant.userId)) {
      setData(keyId, data[Constant.id].toString());
    }
    if (token.trim().isNotEmpty) {
      setData(keyToken, token);
    }
    setData(keyFirstName, data[Constant.firstName]);
    setData(keyLastName, data[Constant.lastName]);
    setData(keyPhone, data[Constant.phone]);
    setData(keyEmail, data[Constant.email]);
    setData(keyActive,
        data.containsKey(Constant.active) ? data[Constant.active] : '1');
    setData(
        keyImage, data.containsKey(Constant.image) ? data[Constant.image] : '');

    if (data.containsKey(Constant.activeSubscription) &&
        data[Constant.activeSubscription] != null) {
      setData(
          keyActiveSubscription, data[Constant.activeSubscription].toString());
      Constant.currsubscriptionPlan =
          Plans.fromSubscriptionJson(data[Constant.activeSubscription]);
    } else {
      setData(keyActiveSubscription, '');
      Constant.currsubscriptionPlan = null;
    }

    if (data.containsKey(Constant.upcomingSubscription) &&
        data[Constant.upcomingSubscription] != null) {

      setData(keyUpcomingSubscription,
          data[Constant.upcomingSubscription].toString());
      Constant.upcomingsubscriptionPlan =
          Plans.fromSubscriptionJson(data[Constant.upcomingSubscription]);
    } else {
      setData(keyUpcomingSubscription, '');
      Constant.upcomingsubscriptionPlan = null;
    }

    setData(keyFcmId, data[Constant.fcmId]);

  }

  void updateUserData(
      String fname, String phone, String lname, String profile) {
    setData(keyFirstName, fname);
    setData(keyLastName, lname);
    setData(keyPhone, phone);

    setData(keyImage, profile);

    notifyListeners();
  }
}

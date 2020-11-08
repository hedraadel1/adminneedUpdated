

import 'dart:ffi';

import 'package:shared_preferences/shared_preferences.dart';

class shareddata{
  static String sharedPreferenceUserLoggedInKey = "ISLOGGEDIN";
  static String sharedphKey = "PHARMCY";
  static String sharedPreferenceUserEmailKey = "USEREMAILKEY";

  /// saving data to sharedpreference
  static Future<bool> IS_FIRST_TIME(bool isUserLoggedIn) async{

    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(sharedPreferenceUserLoggedInKey, isUserLoggedIn);
  }
  static Future<bool> Get_IS_FIRST_TIME() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(sharedPreferenceUserLoggedInKey);
  }
  static Future<bool> IS_FIRST_TIME_ph(bool isUserLoggedIn) async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.setBool(sharedphKey, isUserLoggedIn);
  }
  // static Future<bool> saveUserNameSharedPreference(String userName) async{
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   return await preferences.setString(sharedPreferenceUserNameKey, userName);
  // }
  //
  // static Future<bool> saveUserEmailSharedPreference(String userEmail) async{
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   return await preferences.setString(sharedPreferenceUserEmailKey, userEmail);
  // }
  /// fetching data from sharedpreference
  static Future<bool> Get_IS_FIRST_TIME_ph() async{
    SharedPreferences preferences = await SharedPreferences.getInstance();
    return await preferences.getBool(sharedphKey);
  }


}
import 'dart:convert';
import 'dart:io';

import 'package:adminneed/src/helpers/helper.dart';
import 'package:adminneed/src/models/category.dart';
import 'package:adminneed/src/models/market.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

ValueNotifier<User> currentUser = new ValueNotifier(User());
ValueNotifier<Market> currentMarket = new ValueNotifier(Market());

Future<User> login(User user) async {
  final String url = 'https://www.needeg.com/newneed/public/api/login';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentUser.value = User.fromJSON(json.decode(response.body)['data']);
  } else {
    throw new Exception(response.body);
  }
  return currentUser.value;
}

Future<Stream<Category>> getCategories() async {
  Uri uri =Uri.parse('https://www.needeg.com/newneed/public/api/categories');
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    return streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) => Category.fromJSON(data));
  } catch (e) {
    print(uri.data.toString());
    return new Stream.value(new Category.fromJSON({}));
  }
}

Future<Market> register(Market market) async {
  final String url =
      "https://www.needeg.com/newneed/public/api/manager_create_market";
  final client = new http.Client();

  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(market.toMap()),
  );

  if (response.statusCode == 200) {
    setCurrentUser(response.body);
    currentMarket.value = Market.fromJSON(json.decode(response.body)['data']);
    print(" pharmacyyyyyyyyy ${json.decode(response.body)['data']}");
  } else {
    throw new Exception(response.body);
  }
  return currentMarket.value;
}
//
// Future<User> register(User user) async {
//   final String url = 'https://syringa.app/sy/public/api/register';
//   final client = new http.Client();
//   final response = await client.post(
//     url,
//     headers: {HttpHeaders.contentTypeHeader: 'application/json'},
//     body: json.encode(user.toMap()),
//   );
//   if (response.statusCode == 200) {
//     setCurrentUser(response.body);
//     currentUser.value = User.fromJSON(json.decode(response.body)['data']);
//   } else {
//     throw new Exception(response.body);
//   }
//   return currentUser.value;
// }

Future<bool> resetPassword(User user) async {
  final String url =
      '${GlobalConfiguration().getString('api_base_url')}send_reset_link_email';
  final client = new http.Client();
  final response = await client.post(
    url,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(user.toMap()),
  );
  if (response.statusCode == 200) {
    return true;
  } else {
    throw new Exception(response.body);
  }
}

Future<void> logout() async {
  currentUser.value = new User();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}

void setCurrentUser(jsonString) async {
  if (json.decode(jsonString)['data'] != null) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        'current_user', json.encode(json.decode(jsonString)['data']));
  }
}

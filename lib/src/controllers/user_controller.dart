import 'package:adminneed/src/helpers/authsign.dart';
import 'package:adminneed/src/helpers/helper.dart';
import 'package:adminneed/src/models/category.dart';
import 'package:adminneed/src/models/market.dart';

import 'package:adminneed/src/pages/usersList.dart';
import 'package:adminneed/src/repository/user_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:adminneed/src/models/user.dart';
import 'package:adminneed/src/repository/user_repository.dart' as repository;
import 'package:adminneed/src/controllers/sharedprefrence.dart';

class UserController extends ControllerMVC {
  User user = new User();
  Market market = new Market();

  bool hidePassword = true;
  bool loading = false;
  GlobalKey<FormState> loginFormKey;
  GlobalKey<ScaffoldState> scaffoldKey;
  FirebaseMessaging _firebaseMessaging;
  OverlayEntry loader;
  Position _currentPosition;
  List<Category> categoriesList =  <Category>[];

  UserController() {
    loader = Helper.overlayLoader(context);
    loginFormKey = new GlobalKey<FormState>();
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) {
      user.deviceToken = _deviceToken;
    }).catchError((e) {
      print('Notification not configured');
    });
    _getCurrentLocation();
  }

  void login() async {
    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      if (!user.email.contains("gmail.com")) {
        if (!user.email.contains("yahoo.com")) {
          if (user.email.length >= 11) {
            user.email = "${user.email}@gmail.com";
          } else {
            Fluttertoast.showToast(
                msg: "Please enter vailed phone number Or Email",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            return;
          }
        }
      }
      authsign auth = authsign();
      Overlay.of(context).insert(loader);
      repository.login(user).then((value) async {
        if (value != null) {
          shareddata.saveUserEmailSharedPreference(user.email);
          if (user.email == "admin@gmail.com") {
            await auth.Signin(user.email, user.password);
            await auth.uplode_Admin_info(user.email);
            Navigator.pushReplacement(
                scaffoldKey.currentContext,
                MaterialPageRoute(
                    builder: (context) => usersList(email: user.email)));
          } else {
            await auth.uplode_Admin_market_info(user.email);
            Navigator.pushReplacement(
                scaffoldKey.currentContext,
                MaterialPageRoute(
                    builder: (context) => usersList(email: user.email)));
            // Navigator.pushNamed(scaffoldKey.currentContext, "/UserList",arguments: registerUser.email);
          }
          print("tttt ${user.deviceToken}");
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("Wrong Email Password"),
          ));
        }
      }).catchError((e) {
        loader.remove();
        // scaffoldKey.currentState.showSnackBar(SnackBar(
        //   content: Text("this account not exist"),
        // ));
        print("error e");
      }).whenComplete(() {
        Helper.hideLoader(loader);
        // scaffoldKey.currentState.showSnackBar(SnackBar(
        // content: Text("login"),
        // ));
      });
    }
  }

  void loadCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category categories) {
      setState(() => categoriesList.add(categories));
      print(categoriesList);
    }, onError: (a) {
      print(a);
    }, onDone: () {});
  }

  void register() async {
    // loginFormKey.currentState.save();
    FocusScope.of(context).unfocus();

    bool isLocationEnabled = await Geolocator().isLocationServiceEnabled();

    if (isLocationEnabled == true) {
      _getCurrentLocation();
    } else {
      Fluttertoast.showToast(
          msg: "Please open gps",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }

    if (_currentPosition.latitude == null ||
        _currentPosition.longitude == null) {
      Fluttertoast.showToast(
          msg: "Try again",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
      return;
    }

    if (loginFormKey.currentState.validate()) {
      loginFormKey.currentState.save();
      if (!market.email.contains("gmail.com")) {
        if (!market.email.contains("yahoo.com")) {
          if (market.email.length >= 11) {
            market.email = "${market.email}@gmail.com";
          } else {
            Fluttertoast.showToast(
                msg: "Please enter vailed phone number Or Email",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
            return;
          }
        }
      }
      Overlay.of(context).insert(loader);
      // user.lat = _currentPosition.latitude;
      // user.lng = _currentPosition.longitude;

      repository.register(market).then((value) async {
        if (value != null) {
          authsign auth = authsign();
          final res = await auth.Signup(market.email, market.password);
          await auth.uplodeuserinfo2(
              market.marketName, market.email, user.deviceToken);
          // print(res.registerUser.email);
          shareddata.saveUserEmailSharedPreference(market.email);
          Navigator.of(context).pushNamed('/UserList');
        } else {
          scaffoldKey.currentState.showSnackBar(SnackBar(
            content: Text("wrong email or password"),
          ));
        }
      }).catchError((e) {
        loader.remove();
        scaffoldKey.currentState.showSnackBar(SnackBar(
          content: Text("this email account exists"),
        ));
        print("errorrrrrrrrrrr  $e");
      }).whenComplete(() {
        Helper.hideLoader(loader);
      });
    }
  }

  _getCurrentLocation() {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });
    }).catchError((e) {
      print(e);
    });
  }
// void resetPassword() {
//   FocusScope.of(context).unfocus();
//   if (loginFormKey.currentState.validate()) {
//     loginFormKey.currentState.save();
//     Overlay.of(context).insert(loader);
//     repository.resetPassword(user).then((value) {
//       if (value != null && value == true) {
//         scaffoldKey.currentState.showSnackBar(SnackBar(
//           content: Text(S
//               .of(context)
//               .your_reset_link_has_been_sent_to_your_email),
//           action: SnackBarAction(
//             label: S
//                 .of(context)
//                 .login,
//             onPressed: () {
//               Navigator.of(scaffoldKey.currentContext)
//                   .pushReplacementNamed('/Login');
//             },
//           ),
//           duration: Duration(seconds: 10),
//         ));
//       } else {
//         loader.remove();
//         scaffoldKey.currentState.showSnackBar(SnackBar(
//           content: Text(S
//               .of(context)
//               .error_verify_email_settings),
//         ));
//       }
//     }).whenComplete(() {
//       Helper.hideLoader(loader);
//     });
//   }
// }
}

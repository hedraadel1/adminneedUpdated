import 'package:adminneed/src/elements/T10Colors.dart';
import 'package:adminneed/src/elements/T10Constant.dart';
import 'package:adminneed/src/elements/T10Strings.dart';
import 'package:adminneed/src/elements/T10Widget.dart';
import 'package:adminneed/src/pages/usersList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../controllers/user_controller.dart';
import 'package:adminneed/src/controllers/sharedprefrence.dart';


class Login extends StatefulWidget {
  GlobalKey<FormState> _global = GlobalKey<FormState>();

  bool hidePassword = true;
  bool isloading = false;
  String email;

  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends StateMVC<Login> {
  UserController _con;

  _SigninState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    valid();
    super.initState();
  }

  Future<void> valid() async {
    widget.email = await shareddata.getUserEmailSharedPreference();
    if (widget.email != null) {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => usersList(email: widget.email)));
    } else {
      // Navigator.pushNamed(context, "/SignIn");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _con.scaffoldKey,
      body: Scaffold(
        backgroundColor: t10_white,
        body: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            color: t10_white,
            margin: EdgeInsets.only(left: spacing_large, right: spacing_large),
            child: Form(
              key: _con.loginFormKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  text("Need Admin",
                      fontFamily: fontBold, fontSize: textSizeXLarge),
                  SizedBox(
                    height: spacing_large,
                  ),
                  EditText(
                    // initialValue: "himahamed6@gmail.com",
                    text: "User Email",
                    isPassword: false,
                    onSaved: (input) {
                      setState(() {
                        _con.user.email = input;
                      });
                    },
                    validator: (input) =>
                        !input.contains('@') ? "Enter Vailed Email" : null,
                  ),
                  SizedBox(
                    height: spacing_standard_new,
                  ),
                  EditText(
                    // initialValue: "123456",
                    text: theme10_password,
                    isSecure: true,
                    onSaved: (input) {
                      setState(() {
                        _con.user.password = input;
                      });
                    },
                    validator: (input) => input.length < 3
                        ? "should be more than 3 digits"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_xlarge,
                  ),
                  AppButton(
                    onPressed: () => _con.login(),
                    textContent: theme10_lbl_sign_in,
                  ),
                  SizedBox(
                    height: spacing_large,
                  ),
                  InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        text(theme10_lbl_dont_have_account,
                            textColor: t10_textColorSecondary,
                            fontFamily: fontMedium),
                        SizedBox(
                          width: spacing_control,
                        ),
                        text(theme10_lbl_sign_up, fontFamily: fontMedium),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/SignUp');
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

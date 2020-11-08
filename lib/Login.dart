import 'package:adminneed/BlockButtonWidget.dart';
import 'package:adminneed/usersList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'app_config.dart' as config;
import 'authsign.dart';
class Login extends StatefulWidget {
  GlobalKey<FormState> _global = GlobalKey<FormState>();
 // static String id = "signin";
  String _email, _password;
  bool hidePassword = true;
  authsign auth = authsign();
  GlobalKey<ScaffoldState> _saccfold = GlobalKey<ScaffoldState>();
  bool isloading = false;
  @override
  _SigninState createState() => _SigninState();
}

class _SigninState extends State<Login> {


  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: widget._saccfold,
      body: ModalProgressHUD(
        color: Colors.black12,
        opacity: 1,
        inAsyncCall: widget.isloading,
        child: Stack(
          alignment: AlignmentDirectional.topCenter,
          children: <Widget>[
            Positioned(
              top: 0,
              child: Container(
                width: config.App(context).appWidth(100),
                height: config.App(context).appHeight(37),
                decoration: BoxDecoration(color: Theme.of(context).accentColor),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: 40, left: config.App(context).appWidth(35)),
                  child: Text(
                    "Need",
                    style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.white),
                  ),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 120,
              child: Container(
                width: config.App(context).appWidth(84),
                height: config.App(context).appHeight(37),
                child: Text(
                  "Admin Login",
                  style: Theme.of(context)
                      .textTheme
                      .headline
                      .merge(TextStyle(color: Colors.white)),
                ),
              ),
            ),
            Positioned(
              top: config.App(context).appHeight(37) - 50,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 50,
                        color: Theme.of(context).hintColor.withOpacity(0.2),
                      )
                    ]),
                margin: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                padding:
                    EdgeInsets.only(top: 50, right: 27, left: 27, bottom: 20),
                width: config.App(context).appWidth(88),
//              height: config.App(context).appHeight(55),
                child: Form(
                  key: widget._global,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      TextFormField(
                        validator:(input) => input.length < 11 ? "should be Vailed phone" : null,
                        keyboardType: TextInputType.emailAddress,
                        onSaved: (input) {
                          setState(() {
                            widget._email = input;
                          });
                        },

                        decoration: InputDecoration(
                          labelText: "phone",
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),

                          hintText: '01.......',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.phone,

                              color: Theme.of(context).accentColor),

                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      TextFormField(
                        keyboardType: TextInputType.text,
                        onSaved: (input) {
                          setState(() {
                            widget._password = input;
                          });
                        },
                        validator: (input) => input.length < 3
                            ? "should be more than 3 digits"
                            : null,
                        obscureText: widget.hidePassword,
                        decoration: InputDecoration(
                          labelText: "Enter password",
                          labelStyle:
                              TextStyle(color: Theme.of(context).accentColor),
                          contentPadding: EdgeInsets.all(12),
                          hintText: '••••••••••••',
                          hintStyle: TextStyle(
                              color: Theme.of(context)
                                  .focusColor
                                  .withOpacity(0.7)),
                          prefixIcon: Icon(Icons.lock_outline,
                              color: Theme.of(context).accentColor),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                widget.hidePassword = !widget.hidePassword;
                              });
                            },
                            color: Theme.of(context).focusColor,
                            icon: Icon(widget.hidePassword
                                ? Icons.visibility
                                : Icons.visibility_off),
                          ),
                          border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                          focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.5))),
                          enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Theme.of(context)
                                      .focusColor
                                      .withOpacity(0.2))),
                        ),
                      ),
                      SizedBox(height: 30),
                      BlockButtonWidget(
                        text: Text(
                          "Login",
                          style: TextStyle(color: Colors.white),
                        ),
                        color: Theme.of(context).accentColor,
                        onPressed: () async{
                          if (widget._global.currentState.validate()) {
                            widget._global.currentState.save();
                            setState(() {
                              widget.isloading = true;
                            });
                            print(widget._email);
                            print(widget._password);
                            try {
                              final res=await  widget.auth.Signin("${widget._email}@gmail.com", widget._password);
                              await widget.auth.uplode_Admin_info(widget._email);
                              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => usersList(widget._email,"")));
                              setState(() {
                              widget.isloading = false;
                            });
                            } catch (e) {
                              widget._saccfold.currentState.showSnackBar(SnackBar(content:Text( e.message), elevation: 50,
                                backgroundColor: Colors.redAccent,
                              ));
                              setState(() {
                                widget.isloading = false;
                              });
                            }

                          }
                        },
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

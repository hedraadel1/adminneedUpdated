import 'dart:convert';
import 'dart:io';

import 'package:adminneed/src/elements/CircularLoadingWidget.dart';
import 'package:adminneed/src/elements/T10Colors.dart';
import 'package:adminneed/src/elements/T10Constant.dart';
import 'package:adminneed/src/elements/T10Strings.dart';
import 'package:adminneed/src/elements/T10Widget.dart';
import 'package:adminneed/src/models/AddressData.dart';
import 'package:adminneed/src/models/category.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:http/http.dart' as http;

import '../controllers/user_controller.dart';

class SignUpWidget extends StatefulWidget {
  bool sign = false;
  var image;

  SignUpWidget({this.image});

  @override
  _SignUpWidgetState createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends StateMVC<SignUpWidget> {
  UserController _con;
  AddressData addressData = new AddressData();
  String lineAddress;
  TextEditingController addressController = TextEditingController();
  String _mySelection;

  _SignUpWidgetState() : super(UserController()) {
    _con = controller;
  }

  @override
  void initState() {
    lineAddress = addressData.addressline;
    _con.loadCategories();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    lineAddress = addressData.addressline;
    super.didChangeDependencies();
  }

  void _updateLocation(AddressData _value) {
    setState(() {
      addressData = _value ?? addressData;
      addressController.text = addressData.addressline;
      _con.market.lat = addressData.lat;
      _con.market.lng = addressData.lng;
    });
  }

  @override
  Widget build(BuildContext context) {
    var selectedItem;
    return Scaffold(
      key: _con.scaffoldKey,
      body: Scaffold(
        backgroundColor: t10_white,
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          reverse: true,
          child: Container(
            color: t10_white,
            margin: EdgeInsets.only(left: spacing_large, right: spacing_large),
            child: Form(
              key: _con.loginFormKey,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 35,
                  ),
                  text(theme10_lbl_register,
                      fontFamily: fontBold, fontSize: textSizeXLarge),
                  SizedBox(
                    height: spacing_large,
                  ),
                  EditText(
                    // initialValue: "hima",
                    text: "User Name",
                    isPassword: false,
                    onSaved: (input) => _con.market.userName = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_standard_new,
                  ),
                  EditText(
                    // initialValue: "himahamed10@gmail.com",
                    text: "User Email",
                    isPassword: false,
                    onSaved: (input) => _con.market.email = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_standard_new,
                  ),
                  EditText(
                    // initialValue: "يدلية على",
                    text: "Market Name",
                    isPassword: false,
                    onSaved: (input) => _con.market.marketName = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_standard_new,
                  ),
                  EditText(
                    // initialValue: "123456789",
                    text: "Phone",
                    isPassword: false,
                    onSaved: (input) => _con.market.phone = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_standard_new,
                  ),
                  EditText(
                    // initialValue: "123456789",
                    text: "Mobile",
                    isPassword: false,
                    onSaved: (input) => _con.market.mobile = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_xlarge,
                  ),
                  EditText(
                    // initialValue: "Description",
                    text: "Description",
                    isPassword: false,
                    onSaved: (input) => _con.market.description = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_xlarge,
                  ),
                  new Container(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: new Column(
                        children: <Widget>[
                          new Align(
                              alignment: Alignment.centerLeft,
                              child: new Text("Category",
                                  style: TextStyle(
                                      color: Colors.black54, fontSize: 16))),
                        ],
                      )),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      children: [
                        _con.categoriesList.length != 0
                            ? Expanded(
                                flex: 1,
                                child: new DropdownButton(
                                  isExpanded: true,
                                  items: _con.categoriesList.map((item) {
                                    return new DropdownMenuItem(
                                      child: Text(item.name.toString()),
                                      value: item.id.toString(),
                                    );
                                  }).toList(),
                                  onChanged: (newVal) {
                                    setState(() {
                                      _mySelection = newVal;
                                    });
                                  },
                                  value: _mySelection,
                                ),
                              )
                            : CircularProgressIndicator()
                      ],
                    ),
                  ),
                  SizedBox(
                    height: spacing_xlarge,
                  ),
                  EditText(
                    // initialValue: "Information",
                    text: "Information",
                    isPassword: false,
                    onSaved: (input) => _con.market.information = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_xlarge,
                  ),
                  GpsText(
                    onPressed: () {
                      setState(() {
                        Navigator.of(context)
                            .pushNamed(
                          "/MapScreen",
                          arguments: addressData,
                        )
                            .then(
                          (addressData) {
                            _updateLocation(addressData);
                          },
                        );
                      });
                    },
                    mController: addressController,
                    onSaved: (input) => _con.market.address = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  SizedBox(
                    height: spacing_xlarge,
                  ),
                  EditText(
                    // initialValue: "123456",
                    text: "Password",
                    isSecure: true,
                    onSaved: (input) => _con.market.password = input,
                    validator: (input) => input.length < 3
                        ? "should be more than 3 letters"
                        : null,
                  ),
                  widget.image != null
                      ? Container(
                          margin: EdgeInsets.fromLTRB(0, 16, 0, 0),
                          height: 300,
                          width: MediaQuery.of(context).size.width * 0.70,
                          child:
                              Image.file(File(widget.image), fit: BoxFit.cover))
                      : SizedBox(
                          height: 0,
                        ),
                  SizedBox(
                    height: spacing_xlarge,
                  ),
                  AppButton(
                    onPressed: () {
                      _con.register();
                    },
                    textContent: theme10_lbl_register,
                  ),
                  SizedBox(
                    height: spacing_large,
                  ),
                  InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        text(theme10_lbl_already_have_account,
                            textColor: t10_textColorSecondary,
                            fontFamily: fontMedium),
                        SizedBox(
                          width: spacing_control,
                        ),
                        text(theme10_lbl_sign_in, fontFamily: fontMedium),
                      ],
                    ),
                    onTap: () {
                      Navigator.of(context).pushNamed('/SignIn');
                    },
                  ),
                  SizedBox(
                    height: spacing_large,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
const  kMainColor=Color(0xffFFBF2A);
const ktextColor=Color(0xffFFE3A8);

String _getError(String error) {
  switch (error) {
    case "Enter your Email":
      return "Email is Empty";
    case "Enter your password":
      return "password is Empty";
  }
}


Widget custometextfield(Function onclick, IconData icon, String hint) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    child: TextFormField(

      obscureText: hint == "Enter your password" ? true : false,
      validator: (value) {
        if (value.isEmpty) {
          // ignore: missing_return
          return _getError(hint);
        }
      },
      onSaved: onclick,
      cursorColor: kMainColor,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: kMainColor,
        ),
        filled: true,
        // دي لازم علشان يظهر الباك جراوند بتاعت التكست فيو
        fillColor: ktextColor,
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.white)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide(color: Colors.red)),
      ),
    ),
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'T10Colors.dart';
import 'T10Constant.dart';

Widget text(String text,
    {var fontSize = textSizeMedium,
    textColor = t10_textColorPrimary,
    var fontFamily = fontRegular,
    var isCentered = false,
    var maxLine = 1,
    var lineThrough = false,
    var latterSpacing = 0.25,
    var textAllCaps = false,
    var isLongText = false}) {
  return Text(textAllCaps ? text.toUpperCase() : text,
      textAlign: isCentered ? TextAlign.center : TextAlign.start,
      maxLines: isLongText ? null : maxLine,
      style: TextStyle(
          fontFamily: fontFamily,
          fontSize: fontSize,
          decoration:
              lineThrough ? TextDecoration.lineThrough : TextDecoration.none,
          color: textColor,
          height: 1.5,
          letterSpacing: latterSpacing));
}

class EditText extends StatefulWidget {
  var isPassword;
  var isSecure;
  var text;
  var validator;
  var onSaved;
  var initialValue;
  TextEditingController mController;

  VoidCallback onPressed;

  EditText(
      {var this.isPassword = true,
      var this.isSecure = false,
      var this.text = "",
      var this.mController,
      var this.validator,
      var this.onSaved,
      var this.initialValue});

  @override
  State<StatefulWidget> createState() {
    return EditTextState();
  }
}

class EditTextState extends State<EditText> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isSecure) {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: t10_colorPrimary,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
          hintText: widget.text,
          labelText: widget.text,
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: t10_view_color, width: 0.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: t10_view_color, width: 0.0),
          ),
        ),
        maxLines: 1,
        style: TextStyle(fontSize: 16, color: t10_textColorPrimary),
        initialValue: widget.initialValue,
        validator: widget.validator,
        onSaved: widget.onSaved,
      );
    } else {
      return TextFormField(
        controller: widget.mController,
        obscureText: widget.isPassword,
        cursorColor: t10_colorPrimary,
        decoration: InputDecoration(
          suffixIcon: new GestureDetector(
            onTap: () {
              setState(() {
                widget.isPassword = !widget.isPassword;
              });
            },
            child: new Icon(
                widget.isPassword ? Icons.visibility : Icons.visibility_off),
          ),
          contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
          hintText: widget.text,
          labelText: widget.text,
          enabledBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: t10_view_color, width: 0.0),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: const BorderSide(color: t10_view_color, width: 0.0),
          ),
        ),
        style: TextStyle(fontSize: 16, color: t10_textColorPrimary),
        initialValue: widget.initialValue,
        validator: widget.validator,
        onSaved: widget.onSaved,
      );
    }
  }

  @override
  State<StatefulWidget> createState() {
    return null;
  }
}

class GpsText extends StatefulWidget {
  var text;
  var validator;
  var onSaved;
  var initialValue;
  TextEditingController mController;

  VoidCallback onPressed;

  GpsText(
      {var this.text = "Address",
      var this.mController,
      var this.validator,
      var this.onSaved,
      var this.initialValue,
      var this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return GpsTextState();
  }
}

class GpsTextState extends State<GpsText> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.mController,
      cursorColor: t10_colorPrimary,
      decoration: InputDecoration(
        suffixIcon: new GestureDetector(
          onTap: widget.onPressed,
          child: new Icon(Icons.gps_fixed),
        ),
        contentPadding: EdgeInsets.fromLTRB(16, 8, 4, 8),
        hintText: widget.text,
        labelText: widget.text,
        enabledBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: t10_view_color, width: 0.0),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: const BorderSide(color: t10_view_color, width: 0.0),
        ),
      ),
      style: TextStyle(fontSize: 16, color: t10_textColorPrimary),
      initialValue: widget.initialValue,
      validator: widget.validator,
      onSaved: widget.onSaved,
    );
  }

  @override
  State<StatefulWidget> createState() {
    return null;
  }
}

class DropdownWidget extends StatefulWidget {
  final String title;
  final List<String> items;
  final ValueChanged<String> itemCallBack;
  final String currentItem;
  final String hintText;

  DropdownWidget({
    this.title,
    this.items,
    this.itemCallBack,
    this.currentItem,
    this.hintText,
  });

  @override
  State<StatefulWidget> createState() => _DropdownState(currentItem);
}

class _DropdownState extends State<DropdownWidget> {
  List<DropdownMenuItem<String>> dropDownItems = [];
  String currentItem;

  _DropdownState(this.currentItem);

  @override
  void initState() {
    super.initState();
    for (String item in widget.items) {
      dropDownItems.add(DropdownMenuItem(
        value: item,
        child: Text(
          item,
          style: TextStyle(
            fontSize: 16,
          ),
        ),
      ));
    }
  }

  @override
  void didUpdateWidget(DropdownWidget oldWidget) {
    if (this.currentItem != widget.currentItem) {
      setState(() {
        this.currentItem = widget.currentItem;
      });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 6),
            child: Text(
              widget.title,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(vertical: 3, horizontal: 15),
            margin: EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: Offset(0, 2),
                  blurRadius: 10,
                  color: Color(0x19000000),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                icon: Icon(Icons.arrow_drop_down),
                value: currentItem,
                isExpanded: true,
                items: dropDownItems,
                onChanged: (selectedItem) => setState(() {
                  currentItem = selectedItem;
                  widget.itemCallBack(currentItem);
                }),
                hint: Container(
                  child: Text(widget.hintText, style: TextStyle(color: Colors.black, fontSize: 16)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppButton extends StatefulWidget {
  var textContent;
  VoidCallback onPressed;

  AppButton({@required this.textContent, @required this.onPressed});

  @override
  State<StatefulWidget> createState() {
    return AppButtonState();
  }
}

class AppButtonState extends State<AppButton> {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
        onPressed: widget.onPressed,
        textColor: t10_white,
        elevation: 4,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(80.0)),
        padding: const EdgeInsets.all(0.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.all(Radius.circular(80.0)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text(
                widget.textContent,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ));
  }

  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return null;
  }
}

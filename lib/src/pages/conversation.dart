import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:g_json/g_json.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../models/users.dart';
import '../pages/usersList.dart';
import '../helpers/authsign.dart';

//import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

class Conversation extends StatefulWidget {
  TextEditingController sear = new TextEditingController();
  authsign auth = authsign();
  List<users> data = [];
  bool search = false;
  String id, Email, pharmcy_email;
  Stream<QuerySnapshot> chats;
  File _image;
  String _uploadedFileURL;
  String _token;

  Conversation(this.id, this.Email, this.pharmcy_email);

  bool show = false;

  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final _controller = ScrollController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  String _token;

  void _onRefresh() async {
    // monitor network fetch
    //  await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    authsign m = authsign();
    if (widget.pharmcy_email.isEmpty) {
      m.getMessages(widget.id).then((val) {
        setState(() {
          widget.chats = val;
        });
      });
    } else {
      m.getMessagesPharmacy(widget.pharmcy_email, widget.Email).then((val) {
        setState(() {
          widget.chats = val;
        });
      });
    }
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 3),
      curve: Curves.fastOutSlowIn,
    );
    _refreshController.refreshCompleted();
  }

  void _onLoading() async {
    _refreshController.loadComplete();
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: widget.chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? SmartRefresher(
                enablePullDown: true,
                enablePullUp: true,
                header: WaterDropHeader(),
                footer: CustomFooter(
                  builder: (BuildContext context, LoadStatus mode) {
                    Widget body;
                    if (mode == LoadStatus.idle) {
                      body = Text("pull up load");
                    } else if (mode == LoadStatus.loading) {
                      body = CupertinoActivityIndicator();
                    } else if (mode == LoadStatus.failed) {
                      body = Text("Load Failed!Click retry!");
                    } else if (mode == LoadStatus.canLoading) {
                      body = Text("release to load more");
                    } else {
                      body = Text("No more Data");
                    }
                    return Container(
                      height: 55.0,
                      child: Center(child: body),
                    );
                  },
                ),
                controller: _refreshController,
                onRefresh: _onRefresh,
                onLoading: _onLoading,
                child: ListView.builder(
                    controller: _controller,
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return widget.pharmcy_email.isEmpty
                          ? _chatBubble(
                              snapshot.data.documents[index].data["message"],
                              snapshot.data.documents[index].data["Email"] ==
                                  "admin@gmail.com",
                              snapshot.data.documents[index].data["time"],
                              false,
                              snapshot.data.documents[index].data["image"])
                          : _chatBubble(
                              snapshot.data.documents[index].data["message"],
                              snapshot.data.documents[index].data["Email"] ==
                                  widget.pharmcy_email,
                              snapshot.data.documents[index].data["time"],
                              false,
                              snapshot.data.documents[index].data["image"]);
                    }))
            : Container();
      },
    );
  }

  @override
  void initState() {
    authsign m = authsign();
    if (widget.pharmcy_email.isEmpty) {
      m.getMessages(widget.id).then((val) {
        setState(() {
          widget.chats = val;
        });
      });
    } else {
      m.getMessagesPharmacy(widget.pharmcy_email, widget.Email).then((val) {
        setState(() {
          widget.chats = val;
        });
      });
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        appBar: AppBar(
          title: Text("Chating..."),
        ),
        body: Stack(
          children: [
            chatMessages(),
            Positioned.fill(
                child: Align(
              alignment: Alignment.center,
              child: widget.show ? CircularProgressIndicator() : Container(),
            )),
            Container(
              alignment: Alignment.bottomCenter,
              width: MediaQuery.of(context).size.width,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                height: 70,
                color: Colors.white,
                child: Row(
                  children: <Widget>[
                    IconButton(
                      icon: Icon(Icons.photo),
                      iconSize: 25,
                      color: Theme.of(context).primaryColor,
                      onPressed: () {
                        OpenGalleryAndUplodeImage();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        controller: widget.sear,
                        decoration: InputDecoration.collapsed(
                          hintText: 'Send a message..',
                        ),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      iconSize: 25,
                      color: Theme.of(context).primaryColor,
                      onPressed: () async {
                        sendMessage();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  _chatBubble(
      String message, bool isMe, var time, bool isSameUser, String imge) {
    if (isMe) {
      if (message.isNotEmpty) {
        return Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topRight,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.80,
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            !isSameUser
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        timeString(time),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(
                    child: null,
                  ),
          ],
        );
      } else if (imge.isNotEmpty) {
        return Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(vertical: 10),
                child: ProgressiveImage(
                  placeholder: AssetImage("images/place.jpg"),
                  // size: 1.87KB
                  thumbnail: NetworkImage(imge),
                  // size: 1.29MB
                  image: NetworkImage(imge),
                  height: 200,
                  width: 200,
                ),
              ),
            ),
            !isSameUser
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        timeString(time),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(
                    child: null,
                  ),
          ],
        );
      }
    } else {
      if (message.isNotEmpty) {
        return Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.80,
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                    ),
                  ],
                ),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            ),
            !isSameUser
                ? Row(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        timeString(time),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  )
                : Container(
                    child: null,
                  ),
          ],
        );
      } else if (imge.isNotEmpty) {
        return Column(
          children: <Widget>[
            Container(
              alignment: Alignment.topLeft,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.80,
                ),
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                child: ProgressiveImage(
                  placeholder: AssetImage("images/place.jpg"),
                  // size: 1.87KB
                  thumbnail: NetworkImage(imge),
                  // size: 1.29MB
                  image: NetworkImage(imge),
                  height: 200,
                  width: 200,
                ),
              ),
            ),
            !isSameUser
                ? Row(
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 2,
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        timeString(time),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  )
                : Container(
                    child: null,
                  ),
          ],
        );
      }
    }
  }

  void sendMessage() {
    getToken(widget.Email).then((value) async {
      if (value != null) {
        if (widget.pharmcy_email.isEmpty) {
          if (_token != null) {
            print("tokennnnnnn $_token");
            sendmessage(widget.id, widget.sear.text, "admin@gmail.com", "");
            bool send = await sendFcmMessage(
                widget.sear.text, widget.sear.text, _token);
            if (send == true) {
              Fluttertoast.showToast(
                  msg: "send",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              Fluttertoast.showToast(
                  msg: "Failed ",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          }
        } else {
          if (_token != null) {
            sendFcmMessage(widget.sear.text, widget.sear.text, _token);
          } else {
            print("nullllll");
          }
          final res = await Firestore.instance
              .collection("Conversation")
              .document(widget.pharmcy_email)
              .collection(widget.Email)
              .add({
            "Email": widget.pharmcy_email,
            "message": widget.sear.text,
            "time": DateTime.now().millisecondsSinceEpoch,
            "image": ""
          }).catchError((e) {
            print(e.message);
          });
        }
        widget.sear.text = "";
      }
    }).catchError((e) {
      print("errorrrrrrr  $e");
    });
  }

  Future<String> getToken(String email) async {
    var uri =
        Uri.parse("http://www.needeg.com/newneed/public/api/get-token?email=$email");

    var response = await http.get(uri);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      print("json $json");
      _token = json['data'].toString().replaceAll('[', '').replaceAll(']', '');
      print("tok $_token");
    } else {
      throw new Exception(response.body);
    }
    return _token;
  }

  void sendmessage(
      String id, String message, String Email, String img_url) async {
    if (id != null) {
      final res = await Firestore.instance
          .collection("Conversation")
          .document(id)
          .collection("data")
          .add({
        "Email": Email,
        "message": message,
        "time": DateTime.now().millisecondsSinceEpoch,
        "image": img_url
      }).catchError((e) {
        print(e.message);
      });
    } else {
      print("null values");
    }
  }

  static Future<bool> sendFcmMessage(
      String title, String message, String token) async {
    try {
      var url = 'https://fcm.googleapis.com/fcm/send';
      var header = {
        "Content-Type": "application/json",
        "Authorization":
            "key=AAAAZ5IAycM:APA91bHMIBhqXY-S6RGgpV49fV6c3PC_hNguN5qNEVmkFLEDMLdQlGOLiHn-7-Ai-SC3uV5WiPsg6fEJRNq9VeB7gCBHkj5y_fTcx5SP5-jnFxFsYwL5N3IPGYXkxqP8_dc1XN29IQMu",
      };
      var request = {
        'notification': {'title': title, 'body': message},
        'data': {
          'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          'type': 'COMMENT'
        },
        'to': '$token'
      };

      var client = new http.Client();
      var response =
          await client.post(url, headers: header, body: json.encode(request));

      return true;
    } catch (e, s) {
      print(e);
      return false;
    }
  }

  String timeString(var time) {
    DateTime date = new DateTime.fromMillisecondsSinceEpoch(time);
    var format = new DateFormat("yMd");
    var dateString = format.format(date);
    return dateString;
  }

  void OpenGalleryAndUplodeImage() async {
    await chooseFile();
    if (widget._image != null) {
      setState(() {
        widget.show = true;
      });
      await uploadFile(widget._image);
    }

    setState(() {
      widget.show = false;
    });
  }

  Future chooseFile() async {
    await ImagePicker().getImage(source: ImageSource.gallery).then((image) {
      setState(() {
        widget._image = File(image.path);
      });
    });
  }

  Future uploadFile(File img) async {
    StorageReference storageReference =
        FirebaseStorage.instance.ref().child('chats/${(img.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(img);
    await uploadTask.onComplete;
    print('File Uploaded');
    storageReference.getDownloadURL().then((fileURL) async {
      if (fileURL != null) {
        if (widget.pharmcy_email.isEmpty) {
          sendmessage(widget.id, "", "admin@gmail.com", fileURL);
        } else {
          final res = await Firestore.instance
              .collection("Conversation")
              .document(widget.pharmcy_email)
              .collection(widget.Email)
              .add({
            "Email": widget.pharmcy_email,
            "message": "",
            "time": DateTime.now().millisecondsSinceEpoch,
            "image": fileURL
          }).catchError((e) {
            print(e.message);
          });
        }
      } else {
        Fluttertoast.showToast(
            msg: "Failed to uplode im,,age",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to delete this chat'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () {
                  if (widget.pharmcy_email.isEmpty) {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                usersList(email: "admin@gmail.com")),
                        (Route<dynamic> route) => false);
                  } else {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                usersList(email: widget.pharmcy_email)),
                        (Route<dynamic> route) => false);
                  }
                },
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () {
                  if (widget.pharmcy_email.isEmpty) {
                    widget.auth.deleteMessages(widget.id);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                usersList(email: "admin@gmail.com")),
                        (Route<dynamic> route) => false);
                  } else {
                    widget.auth.deleteMessagesforpharmcy(
                        widget.Email, widget.pharmcy_email);
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                usersList(email: widget.pharmcy_email)),
                        (Route<dynamic> route) => false);
                  }
                },
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
  }
}

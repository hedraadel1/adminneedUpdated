import 'dart:io';

import 'package:adminneed/authsign.dart';
import 'package:adminneed/users.dart';
import 'package:adminneed/usersList.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
//import 'package:rflutter_alert/rflutter_alert.dart';

class Conversation extends StatefulWidget {
  TextEditingController sear = new TextEditingController();
  authsign auth = authsign();
  List<users> data = [];
  bool search = false;
  String id, Email,Admin_email;
  Stream<QuerySnapshot> chats;
  File _image;
  String _uploadedFileURL;
  Conversation(this.id, this.Email,this.Admin_email);
  bool show = false;
  @override
  _ConversationState createState() => _ConversationState();
}

class _ConversationState extends State<Conversation> {
  final _controller = ScrollController();

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    // monitor network fetch
    //  await Future.delayed(Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    authsign m = authsign();
      m.getMessages(widget.id).then((val) {
        setState(() {
          widget.chats = val;
        });
      });

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
                      return  _chatBubble(
                          snapshot.data.documents[index].data["message"],
                          snapshot.data.documents[index].data["Email"]==widget.Admin_email,
                          snapshot.data.documents[index].data["time"], false,
                          snapshot.data.documents[index].data["image"]);

                    }))
            : Container();
      },
    );
  }

  @override
  void initState() {
    authsign m = authsign();
      m.getMessages(widget.id).then((val) {
        setState(() {
          widget.chats = val;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Color(0xFFF6F6F6),
        appBar: AppBar(
          title:Text("Chating..."),
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
                      onPressed: ()async {

  sendmessage(
      widget.id, widget.sear.text, widget.Admin_email, "");

                        widget.sear.text="";
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

          sendmessage(widget.id, "", widget.Admin_email, fileURL);

      } else {
        Fluttertoast.showToast(
            msg: "Failed to uplode image",
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
            onTap: (){

                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            usersList(widget.Admin_email, "")),
                        (Route<dynamic> route) =>
                    false);

    },
            child: Text("NO"),
          ),
          SizedBox(height: 16),
          new GestureDetector(
            onTap: () {

      widget.auth.deleteMessages(widget.id);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  usersList(widget.Admin_email, "")),
              (Route<dynamic> route) =>
          false);

    },
            child: Text("YES"),
          ),
        ],
      ),
    ) ??
        false;
  }
}

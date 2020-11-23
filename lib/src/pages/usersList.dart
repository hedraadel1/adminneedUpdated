import '../models/user.dart';
import '../pages/web_view.dart';
import '../repository/user_repository.dart';

import '../helpers/authsign.dart';
import 'conversation.dart';
import '../models/users.dart';
import '../models/usersph.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class usersList extends StatefulWidget {
  authsign auth = authsign();
  String email, status;
  ValueNotifier<User> currentUser = new ValueNotifier(User());

  usersList({this.email, this.status});

  @override
  _usersListState createState() => _usersListState();
}

class _usersListState extends State<usersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        title: Text("Users List"),
        leading: new IconButton(
          icon: new Icon(Icons.dashboard, color: Colors.white),
          onPressed: () async {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => open_webview(
                        "https://www.needeg.com/newneed/public/login")));
          },
        ),
        actions: <Widget>[
          new IconButton(
            icon: Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              if (widget.currentUser.value != null) {
                logout().then((value) {
                  Navigator.of(context).pushNamed('/SignIn');
                });
              }
            },
          )
        ],
      ),
      body: widget.email == "admin@gmail.com"
          ? FutureBuilder<List<users>>(
              future: widget.auth.getusers(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.grey[300],
                          elevation: 1,
                          child: ListTile(
                            trailing: Container(
                              child: Center(
                                child: Text(
                                  snapshot.data[index].count.toString(),
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.caption.merge(
                                            TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                ),
                              ),
                              padding: EdgeInsets.all(0),
                              decoration: BoxDecoration(
                                  color: snapshot.data[index].count == 0
                                      ? Colors.red
                                      : Colors.blue,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(50))),
                              constraints: BoxConstraints(
                                  minWidth: 25,
                                  maxWidth: 25,
                                  minHeight: 25,
                                  maxHeight: 25),
                            ),
                            leading: CircleAvatar(
                              child: Image.asset("images/male.png"),
                            ),
                            onTap: () {
                              if (snapshot.data[index].email.isNotEmpty) {
                                String id =
                                    "admin@gmail.com-${snapshot.data[index].email}";
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Conversation(id,
                                            snapshot.data[index].email, "")));
                              }
                            },
                            title: Text(
                              snapshot.data[index].name,
                              style: TextStyle(fontSize: 15),
                            ),
                            subtitle: Text(
                              snapshot.data[index].email,
                              style: TextStyle(fontSize: 15),
                            ),
                          ),
                        );
                      });
                } else {
                  return Center(
                      child: Container(
                    child: CircularProgressIndicator(),
                  ));
                }
              })
          : FutureBuilder<List<usersph>>(
              // future: widget.status.isEmpty? widget.auth.getusers():widget.auth.getusersForPharmcy(),
              future: widget.auth.getuserByname(widget.email),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                      padding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        return Card(
                          color: Colors.grey[300],
                          elevation: 1,
                          child: ListTile(
                              leading: CircleAvatar(
                                child: Image.asset("images/male.png"),
                              ),
                              onTap: () {
                                if (snapshot.data[index].email.isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Conversation(
                                              "",
                                              snapshot.data[index].email,
                                              widget.email)));
                                }
                              },
                              title: Text(
                                "Guest",
                                style: TextStyle(fontSize: 15),
                              ),
                              subtitle: snapshot.data[index].email != null
                                  ? Text(
                                      snapshot.data[index].email,
                                      style: TextStyle(fontSize: 15),
                                    )
                                  : SizedBox(
                                      height: 0,
                                    )),
                        );
                      });
                } else {
                  return Center(
                      child: Container(
                    child: CircularProgressIndicator(),
                  ));
                }
              }),
      floatingActionButton: widget.email == "admin@gmail.com"
          ? FloatingActionButton.extended(
              onPressed: () {
                // SendAllDialog(context: context);
              },
              icon: Icon(Icons.send),
              label: Text("Send To All"),
              backgroundColor: Colors.blue,
            )
          : SizedBox(),
    );
  }
}

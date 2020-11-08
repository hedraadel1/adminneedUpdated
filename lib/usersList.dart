import 'package:adminneed/authsign.dart';
import 'package:adminneed/conversation.dart';
import 'package:adminneed/users.dart';
import 'package:adminneed/usersph.dart';
import 'package:adminneed/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class usersList extends StatefulWidget {
  authsign auth = authsign();
  String Email, status;

  usersList(this.Email, this.status);

  @override
  _usersListState createState() => _usersListState();
}

class _usersListState extends State<usersList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: Text("Users List"),
        ),
        body: FutureBuilder<List<usersph>>(
                future: widget.auth.getuserByname(widget.Email),
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
                              trailing: Icon(Icons.arrow_forward_ios),
                              leading: CircleAvatar(
                                child: Image.asset("images/male.png"),
                              ),
                              onTap: () {
                                if (snapshot.data[index].email.isNotEmpty) {
                                  String id = "${widget.Email}-${snapshot.data[index].email}";
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Conversation(
                                              id,
                                              snapshot.data[index].email, widget.Email)));
                                }
                              },
                              title: Text(
                                "User",
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
                }));
  }
}

import '../models/users.dart';
import '../models/usersph.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:adminneed/src/controllers/sharedprefrence.dart';

class authsign {
  final Firestore _firestore = Firestore.instance;

  createchatroom(String chatroomid, chatroomdata) {
    _firestore
        .collection("ChatsRoom")
        .document(chatroomid)
        .setData(chatroomdata);
  }

//   Future<List<users>> getusersForPharmcy(String Email) async {
//
//     for (var doc in re.documents) {
// print("asddddddddddddddddddddddddddd====${doc.documentID}");
// Fluttertoast.showToast(
//     msg: "asddddddddddddddddddddddddddd====${doc.documentID}",
//     toastLength: Toast.LENGTH_SHORT,
//     gravity: ToastGravity.CENTER,
//     timeInSecForIosWeb: 1,
//     backgroundColor: Colors.red,
//     textColor: Colors.white,
//     fontSize: 16.0);
//     }
//
// return data;
//
//   }
  getMessagesPharmacy(String phone, String email) async {
    return await _firestore
        .collection("Conversation")
        .document(phone)
        .collection(email)
        .orderBy("time")
        .snapshots();
  }

  Future<List<usersph>> getuserByname(String pharmcyemail) async {
    List<usersph> data = [];
    final re = await Firestore.instance
        .collection("UsersMarkets")
        .where("MarketsEmail", isEqualTo: pharmcyemail)
        .getDocuments();
    for (var doc in re.documents) {
      data.add(usersph(doc.data["Email"]));
    }
    return data;
  }

  Future<List<users>> getusers() async {
    List<users> data = [];
    final re = await Firestore.instance.collection("UsersMarkets").getDocuments();
    for (var doc in re.documents) {
      int count = await getCount(doc.data["Email"]);
      data.add(users(doc.data["name"], doc.data["Email"], count));
    }
    data.sort((a, b) => a.count.compareTo(b.count));

    return data;
  }

  uplodeuserinfo(String email, String name) {
    _firestore.collection("Users").add({"name": name, "Email": email});
  }

  uplodeuserinfo2(String name, String email, String token)  {
    _firestore
        .collection("AdminMarket")
        .add({"name": name, "Email": email, "token": token});
  }



  final _auth = FirebaseAuth.instance;

  Future<AuthResult> Signup(String email, String password) async {
    final authresut = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return authresut;
  }

  Future<AuthResult> Signin(String email, String password) async {
    final authresut = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return authresut;
  }

  Future restPAAWORD(String Email) async {
    return await _auth.sendPasswordResetEmail(email: Email);
  }

  Future SignOut() async {
    return await _auth.signOut();
  }

  getMessages(String id) async {
    return await _firestore
        .collection("Conversation")
        .document(id)
        .collection("data")
        .orderBy("time")
        .snapshots();
  }

  deleteMessages(String id) async {
    _firestore
        .collection('Conversation')
        .document(id)
        .collection("data")
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  Future<int> getCount(String email) async {
    String id = "admin@gmail.com-${email}";
    final ressult = await _firestore
        .collection("Conversation")
        .document(id)
        .collection("data")
        .getDocuments();
    int count = await ressult.documents.length;
    print(count);
    return count;
  }

  void deleteMessagesforpharmcy(String email, String pharmcy_email) {
    _firestore
        .collection('Conversation')
        .document(pharmcy_email)
        .collection(email)
        .getDocuments()
        .then((snapshot) {
      for (DocumentSnapshot doc in snapshot.documents) {
        doc.reference.delete();
      }
    });
  }

  uplode_Admin_info(String Email) async {
    bool firsttime = false;
    firsttime = await shareddata.Get_IS_FIRST_TIME();
    print(firsttime);
    if(firsttime==null)
    {
      firsttime=false;
    }

    FirebaseMessaging _firebaseMessaging;
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) async {
      if (_deviceToken.isNotEmpty) {
        if (!firsttime) {
          try {
            _firestore
                .collection("Admin")
                .document(Email)
                .setData({"Email": Email, "token": _deviceToken});
            await shareddata.IS_FIRST_TIME(true);
          } catch (e) {}
        } else {
          try {
            _firestore
                .collection("Admin")
                .document(Email)
                .updateData({"Email": Email, "token": _deviceToken});
          } catch (e) {}
        }
      }
    });

  }

  uplode_Admin_market_info(String Email) async {
    bool firsttime=false;
    firsttime = await shareddata.Get_IS_FIRST_TIME_ph();
    if(firsttime==null)
    {
      firsttime=false;
    }
    print("hjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjjj${firsttime}");
    FirebaseMessaging _firebaseMessaging;
    _firebaseMessaging = FirebaseMessaging();
    _firebaseMessaging.getToken().then((String _deviceToken) async {
      if (_deviceToken.isNotEmpty) {
        if (!firsttime) {
          try {
            _firestore
                .collection("AdminMarket")
                .document(Email)
                .setData({"Email": Email, "token": _deviceToken});
            await shareddata.IS_FIRST_TIME_ph(true);
          } catch (e) {}
        } else {
          try {
            _firestore
                .collection("AdminMarket")
                .document(Email)
                .updateData({"Email": Email, "token": _deviceToken});
          } catch (e) {}
        }
      }
    });
  }


}

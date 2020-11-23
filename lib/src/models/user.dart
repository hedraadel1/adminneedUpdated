
class User {
  String id;
  String name;
  String email;
  String password;
  String deviceToken;
  double lat;
  double lng;

  User();

  User.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      name = jsonMap['name'] != null ? jsonMap['name'] : '';
      email = jsonMap['email'] != null ? jsonMap['email'] : '';
      password = jsonMap['password'] != null ? jsonMap['password'] : '';
      deviceToken = jsonMap['device_token'];
      lat = jsonMap['latitude'] != null ? jsonMap['latitude'] : '';
      lng = jsonMap['longitude'] != null ? jsonMap['longitude'] : '';
    } catch (e) {
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["email"] = email;
    map["name"] = name;
    map["password"] = password;
    if (deviceToken != null) {
      map["device_token"] = deviceToken;
    }
    map["latitude"] = lat;
    map["longitude"] = lng;
    return map;
  }
}

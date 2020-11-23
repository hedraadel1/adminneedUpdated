class Market {
  String userName;
  String email;
  String marketName;
  String phone;
  String mobile;
  String address;
  String description;
  String information;
  String password;
  String image;
  double lat;
  double lng;

  Market();

  Market.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      userName = jsonMap['name'];
      email = jsonMap['email'];
      marketName = jsonMap['market_name'];
      phone = jsonMap['phone'];
      mobile = jsonMap['mobile'];
      address = jsonMap['address'];
      description = jsonMap['description'];
      information = jsonMap['information'];
      password = jsonMap['password'];
      image = jsonMap['image'];
      lat = jsonMap['latitude'];
      lng = jsonMap['longitude'];
    } catch (e) {
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["name"] = userName;
    map["email"] = email;
    map["market_name"] = marketName;
    map["phone"] = phone;
    map["mobile"] = mobile;
    map["address"] = address;
    map["description"] = description;
    map["information"] = information;
    map["password"] = password;
    map["image"] = image;
    map["latitude"] = lat;
    map["longitude"] = lng;
    return map;
  }
}

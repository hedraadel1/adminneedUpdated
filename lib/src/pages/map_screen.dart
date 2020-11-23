import 'dart:ffi';

import 'package:adminneed/src/models/AddressData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class MapScreen extends StatefulWidget {
  double lat, lng;

  LatLng currentPosition;
  var stringLocation;

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<Marker> myMarker = [];
  LocationData myLocation;
  Location location;

  @override
  void initState() {
    getUserLocation();
    location = new Location();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
                target: widget.lat != null
                    ? LatLng(widget.lat, widget.lng)
                    : LatLng(30.0316829, 31.212204),
                zoom: 14.0),
            markers: Set.from(myMarker),
            onTap: _handleTap,
          ),
          Positioned(
            bottom: 16,
            right: 0,
            left: 0,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    onPressed: () {
                      send();
                    },
                    label: Text("Save"),
                    backgroundColor: Colors.blue,
                  ),
                ]),
          )
        ],
      ),
    );
  }

  void _handleTap(LatLng tappedPoint) {
    setState(() {
      myMarker = [];
      myMarker.add(Marker(
          markerId: MarkerId(tappedPoint.toString()), position: tappedPoint));
      widget.currentPosition = tappedPoint;
      print("latttttt  ${tappedPoint.latitude}");
    });
  }

  Future<void> send() async {
    Coordinates coordinates = new Coordinates(
        widget.currentPosition.latitude, widget.currentPosition.longitude);

    var addresses =
    await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;

    var loca =
        "${first.adminArea}-${first.addressLine}-${first.featureName}";

    try {
      myLocation = await location.getLocation();
    } catch (e) {
      myLocation = null;
    }

    AddressData model = AddressData();
    model.lng = myLocation.longitude;
    model.lat = myLocation.latitude;
    model.addressline = loca;

    Navigator.of(context).pop<AddressData>(model);
  }

  Future<Void> getUserLocation() async {
    //call this async method from whereever you need

    String error;
    try {
      myLocation = await location.getLocation();
    } catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
    widget.lng = myLocation.longitude;
    widget.lat = myLocation.latitude;
  }
}

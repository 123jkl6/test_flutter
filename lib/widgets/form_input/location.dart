import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart' as geoloc;
import 'dart:convert';

import '../../models/location_data.dart';
import '../../models/product.dart';
import '../helpers/ensure-visible.dart';

import '../../shared/keys.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  final Product product;

  LocationInput(this.setLocation, this.product);

  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  final FocusNode _addressInputFocusNode = FocusNode();
  Uri _staticMapUri;
  final TextEditingController _addressInputController = TextEditingController();
  LocationData _locationData;

  @override
  void initState() {
    _addressInputFocusNode.addListener(_updateLocation);
    if (widget.product != null && widget.product.location.address != null) {
      _getStaticMap(widget.product.location.address, geocode: false);
    }
    //getStaticMap();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _addressInputFocusNode.removeListener(_updateLocation);
  }

  void _getStaticMap(String input,
      {bool geocode = true, double latitude, double longitude}) async {
    if (input.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    if (geocode) {
      final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json',
          {'address': input, 'key': Keys.geoApi});
      final http.Response response = await http.get(uri);
      final decodedResponse = json.decode(response.body);
      final formattedAddress =
          decodedResponse['results'][0]['formatted_address'];
      final coords = decodedResponse['results'][0]['geometry']['location'];
      print(decodedResponse);
      final LocationData locationData = LocationData(
          address: formattedAddress,
          latitude: coords['lat'],
          longitude: coords['lng']);
      _locationData = locationData;
    } else if (latitude == null || longitude == null) {
      _locationData = widget.product.location;
    } else {
      _locationData = LocationData(
          address: input, latitude: latitude, longitude: longitude);
    }

    //execute only if the page is still mounted and not navigated.
    if (mounted) {
      final StaticMapProvider staticMapProvider =
          StaticMapProvider(Keys.geoApi);
      final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
        Marker('position', 'Position', _locationData.latitude,
            _locationData.longitude)
      ],
          center: Location(_locationData.latitude, _locationData.longitude),
          width: 500,
          height: 300,
          maptype: StaticMapViewType.roadmap);
      widget.setLocation(_locationData);
      setState(() {
        _addressInputController.text = _locationData.address;
        _staticMapUri = staticMapUri;
      });
    }
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      _getStaticMap(_addressInputController.text);
    }
  }

  Future<String> _getAddress(double latitude, double longitude) async {
    final uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json', {
      'latlng': '${latitude.toString()},${longitude.toString()}',
      'key': Keys.geoApi,
    });
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    return formattedAddress;
  }

  _getUserLocation() async {
    final location = geoloc.Location();
    location.requestService().then((bool allowed) async {
      if (allowed) {
        final currentLocation = await location.getLocation();
        print(currentLocation.latitude);
        print(currentLocation.longitude);
        final address = await _getAddress(
            currentLocation.latitude, currentLocation.longitude);
        _getStaticMap(address,
            geocode: false,
            latitude: currentLocation.latitude,
            longitude: currentLocation.longitude);
      } else {
        print('permission denied, do nothing. ');
      }
    }).catchError((err) {
      print(err);
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text("Could not fetch location"),
                content: Text("Please add adress manually"),
                actions: <Widget>[
                  FlatButton(
                      child: Text("Okay"),
                      onPressed: () {
                        Navigator.pop(context);
                      })
                ]);
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        EnsureVisibleWhenFocused(
          child: TextFormField(
              focusNode: _addressInputFocusNode,
              controller: _addressInputController,
              validator: (String value) {
                if (_locationData == null || value.isEmpty) {
                  return 'No valid location found. ';
                }
              },
              decoration: InputDecoration(labelText: 'Address')),
          focusNode: _addressInputFocusNode,
        ),
        SizedBox(height: 10.0),
        FlatButton(child: Text('Locate me'), onPressed: _getUserLocation),
        SizedBox(height: 10.0),
        _staticMapUri != null
            ? Image.network(_staticMapUri.toString())
            : Text('No location.'),
      ],
    );
  }
}

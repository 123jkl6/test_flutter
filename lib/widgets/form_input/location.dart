import 'package:flutter/material.dart';
import 'package:map_view/map_view.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../models/location_data.dart';
import '../helpers/ensure-visible.dart';

class LocationInput extends StatefulWidget {
  final Function setLocation;
  LocationInput(this.setLocation);

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
    //getStaticMap();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _addressInputFocusNode.removeListener(_updateLocation);
  }

  void getStaticMap(String input) async {
    if (input.isEmpty) {
      setState(() {
        _staticMapUri = null;
      });
      widget.setLocation(null);
      return;
    }
    final Uri uri = Uri.https('maps.googleapis.com', '/maps/api/geocode/json',
        {'address': input, 'key': 'AIzaSyASUlBYy7YODpbnRDBUgsXBINAEpY8GlmI'});
    final http.Response response = await http.get(uri);
    final decodedResponse = json.decode(response.body);
    final formattedAddress = decodedResponse['results'][0]['formatted_address'];
    final coords = decodedResponse['results'][0]['geometry']['location'];
    print(decodedResponse);
    final LocationData locationData = LocationData(
        address: formattedAddress,
        latitude: coords['lat'],
        longitude: coords['lng']);
    _locationData = locationData;
    final StaticMapProvider staticMapProvider =
        StaticMapProvider('AIzaSyASUlBYy7YODpbnRDBUgsXBINAEpY8GlmI');
    final Uri staticMapUri = staticMapProvider.getStaticUriWithMarkers([
      Marker(
          'position', 'Position', locationData.latitude, locationData.longitude)
    ],
        center: Location(locationData.latitude, locationData.longitude),
        width: 500,
        height: 300,
        maptype: StaticMapViewType.roadmap);
        widget.setLocation(locationData);
    setState(() {
      _addressInputController.text = locationData.address;
      _staticMapUri = staticMapUri;
    });
  }

  void _updateLocation() {
    if (!_addressInputFocusNode.hasFocus) {
      getStaticMap(_addressInputController.text);
    }
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
        _staticMapUri!=null?Image.network(_staticMapUri.toString()):Text('No location.'),
      ],
    );
  }
}

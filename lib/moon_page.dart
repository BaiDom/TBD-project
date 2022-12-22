import 'dart:ui';

import 'package:flutter/material.dart';

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

Future<String> postData(Position location) async {
  DateTime dateToday = DateTime.now();
  String date = dateToday.toString().substring(0, 10);
  var res = await http.post(
    Uri.parse('https://api.astronomyapi.com/api/v2/studio/moon-phase'),
    body: jsonEncode({
      "format": "png",
      "style": {
        "moonStyle": "sketch",
        "backgroundStyle": "stars",
        "backgroundColor": "red",
        "headingColor": "white",
        "textColor": "red"
      },
      "observer": {"latitude": 6.56774, "longitude": 79.88956, "date": date},
      "view": {"type": "portrait-simple", "orientation": "south-up"}
    }),
    headers: {
      HttpHeaders.authorizationHeader:
          'Basic Mzg3ZTgwOTYtZjA0ZC00Zjg1LWE3MzItNDk4MGQ5NGI4MjYwOjg5ODZkMTQ3NmYzMzljZWMzOTUzNzgwOWE2OWViOTk2NGFiMzZiOWIwNTgyNWE4NzdiNDg3N2MwY2I1MDZmZjcwOWRiOWIzYjljNTk3YzQ3NDYyMGZlMGVjMWY4N2QwY2M4MjA1ZDYzOTdkMTMyMzVhMWVhZDY1OGVjODQzNWI0YTJkMjdkMTYyNDIyMmYwZjc3YzBkNzYzMmIwMGM4MzBjYzk5YmM5MjIwZTgyOWQ3NTY0YTkyYzk1N2UxYjUyOGE2OTg2MjcxNzM2MDkxMWExNDRlMTRlNWE5NzVhZTZm', //baisc api token here
    },
  );
  var body = jsonDecode(res.body);
  final String starChartUrl = body['data']['imageUrl'];
  print(starChartUrl);
  return starChartUrl;
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentAddress;
  Position? _currentPosition;
  String? imageUrl;

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => _currentPosition = position);
      _getAddressFromLatLng(_currentPosition!);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            _currentPosition!.latitude, _currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        _currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Location Page")),
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('LAT: ${_currentPosition?.latitude ?? ""}'),
                Text('LNG: ${_currentPosition?.longitude ?? ""}'),
                Text('ADDRESS: ${_currentAddress ?? ""}'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    _getCurrentPosition().then((_) async {
                      var imageUrl = await postData(_currentPosition!);
                      print('success?');
                      setState(() {
                        this.imageUrl = imageUrl;
                      });
                    });
                  },
                  child: const Text("Get Current Location"),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
          appBar: AppBar(
            title: const Text('API call'),
          ),
          body: Center(
              child: Column(children: [
            Image.network(imageUrl!),
          ])));
    }
  }
}

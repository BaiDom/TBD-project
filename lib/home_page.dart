import 'package:flutter/material.dart';
import 'package:test_project/location_page.dart';
import 'package:test_project/star_map.dart';
import 'package:test_project/starapi.dart';
import 'apod.dart';
import 'starapi.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          title: FittedBox(
            fit: BoxFit.cover,
            child: const Text('stAR.',
                style: TextStyle(
                  color: Colors.black,
                  fontFamily: "MartianMono",
                  fontWeight: FontWeight.bold,
                )),
          )),
      body: Center(
        child: Column(children: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const APOD();
                  },
                ),
              );
            },
            child: Text('Astronomy Picture Of The Day',
                style: TextStyle(fontFamily: "MartianMono")),
          ),
        ]),
      ),
    );
  }
}

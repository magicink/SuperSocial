import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    return MaterialApp(
      title: 'SuperSocial',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          accentColor: Colors.teal[200], primarySwatch: Colors.deepPurple),
      home: Home(),
    );
  }
}

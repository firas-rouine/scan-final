import 'package:flutter/material.dart';
import 'package:scan/home.dart';

import 'package:scan/welcom.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WelcomScreen(),
    );
  }
}

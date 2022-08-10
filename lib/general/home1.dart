import 'package:flutter/material.dart';
import 'package:mychat/general/home.dart';
import 'package:mychat/general/home2.dart';

class Home1 extends StatefulWidget {
  final bool isCameFromLogin;
  const Home1({Key? key, required this.isCameFromLogin}) : super(key: key);

  @override
  State<Home1> createState() => _Home1State();
}

class _Home1State extends State<Home1> {
  @override
  Widget build(BuildContext context) {
    return widget.isCameFromLogin ? const Home2() : const Home();
  }
}

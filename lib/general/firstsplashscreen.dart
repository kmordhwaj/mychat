import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mychat/general/loginscreen.dart';
import 'package:shimmer/shimmer.dart';

class FirstSplashScreen extends StatefulWidget {
  const FirstSplashScreen({Key? key}) : super(key: key);

  @override
  State<FirstSplashScreen> createState() => _FirstSplashScreenState();
}

class _FirstSplashScreenState extends State<FirstSplashScreen> {
  @override
  void initState() {
    Timer(
        const Duration(seconds: 3),
        () => Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const LogInScreen())));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [Colors.deepPurple.shade900, Colors.pink.shade900])),
        child: Center(
          child: SizedBox(
            width: 250,
            height: 100,
            child: Shimmer.fromColors(
                highlightColor: Colors.red,
                baseColor: Colors.green,
                child: Image.asset(
                  'assets/images/logo.png',
                  fit: BoxFit.cover,
                )),
          ),
        ),
      ),
    );
  }
}

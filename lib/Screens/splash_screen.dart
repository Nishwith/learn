import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/Screens/home_page.dart';
import 'package:learn/Screens/login_page.dart';
import 'package:learn/Screens/register_page.dart';
import 'package:learn/Screens/waiting_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    initialState();
  }

  Future<void> initialState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var uid = prefs.getString('uid');
    Widget initialScreen = const LoginPage();
    if (uid != null) {
      try {
        FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get()
            .then((DocumentSnapshot documentSnapshot) {
          if (documentSnapshot.exists) {
            String? registrationStatus = documentSnapshot['Registration'];
            if (registrationStatus == "approved") {
              initialScreen = const HomePage();
            } else if (registrationStatus == "waiting") {
              initialScreen = const WaitingPage();
            } else if (registrationStatus == "pending") {
              initialScreen = const RegisterPage();
            } else {
              initialScreen = const LoginPage();
            }
          }
        });
      } catch (e) {
        initialScreen = const LoginPage();
      }
    } else {
      initialScreen = const LoginPage();
    }
    Timer(const Duration(milliseconds: 2500), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => initialScreen));
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("assets/images/logo.webp"),
            ),
            CircularProgressIndicator(
              color: Color.fromRGBO(236, 187, 32, 1),
            )
          ],
        ),
      ),
    );
  }
}

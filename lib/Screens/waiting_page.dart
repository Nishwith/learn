import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:learn/Screens/home_page.dart';
import 'package:learn/Screens/login_page.dart';
import 'package:learn/Screens/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaitingPage extends StatefulWidget {
  const WaitingPage({super.key});

  @override
  State<WaitingPage> createState() => _WaitingPageState();
}

class _WaitingPageState extends State<WaitingPage> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 16,
            ),
            const Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Image(
                image: AssetImage("assets/images/logo.webp"),
                width: 100,
                height: 100,
              ),
            ]),
            const Center(
              child: Image(
                image: AssetImage("assets/images/waiting.png"),
                width: 200,
                height: 200,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Welcome to LEarn!",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontFamily: "poppins",
                  fontSize: 20),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Waitlist",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Color.fromRGBO(236, 187, 32, 1),
                  fontWeight: FontWeight.w600,
                  fontFamily: "poppins",
                  fontSize: 32),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: const BoxDecoration(
                  color: Color.fromARGB(16, 255, 255, 255),
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              margin: const EdgeInsets.symmetric(horizontal: 30),
              padding: const EdgeInsets.all(10),
              child: const Text(
                "Your profile is under review for verification. Once approved, you'll get full access to the LEarn platform.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                    fontFamily: "poppins",
                    fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            InkWell(
              onTap: () async {
                setState(() {
                  isLoading = true;
                });
                SharedPreferences prefs = await SharedPreferences.getInstance();
                var uid = prefs.getString('uid');
                if (uid != null) {
                  try {
                    FirebaseFirestore.instance
                        .collection('users')
                        .doc(uid)
                        .get()
                        .then((DocumentSnapshot documentSnapshot) {
                      if (documentSnapshot.exists) {
                        String? registrationStatus =
                            documentSnapshot['Registration'];
                        if (registrationStatus == "approved") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                margin: EdgeInsets.all(20),
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                    'Hey!! You are successfully Registered into LEarn.')),
                          );
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const HomePage()));
                        } else if (registrationStatus == "waiting") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                margin: EdgeInsets.all(20),
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                    'Sorry for the inconvince! You are in the Waitlist.')),
                          );
                        } else if (registrationStatus == "pending") {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                margin: EdgeInsets.all(20),
                                behavior: SnackBarBehavior.floating,
                                content: Text('You are not yet Registered.')),
                          );
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RegisterPage()));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                margin: EdgeInsets.all(20),
                                behavior: SnackBarBehavior.floating,
                                content: Text(
                                    'Sorry for the inconvince! You are in the Waitlist.')),
                          );
                        }
                      }
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          margin: EdgeInsets.all(20),
                          behavior: SnackBarBehavior.floating,
                          content: Text(
                              'Sorry for the inconvince! You are in the Waitlist.')),
                    );
                  }
                } else {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()));
                }
                setState(() {
                  isLoading = false;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(50),
                  color: const Color.fromRGBO(236, 187, 32, 1),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                      : const Text(
                          "Check",
                          style: TextStyle(
                              fontFamily: "Poppins",
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 26),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

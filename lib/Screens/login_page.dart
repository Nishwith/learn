import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learn/Screens/reset_password.dart';
import 'package:learn/Screens/signup_page.dart';
import 'package:learn/Screens/splash_screen.dart';
import 'package:learn/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  Future<void> googleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // Sign in with Firebase using the Google credential
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      // Check if the user is new
      if (userCredential.additionalUserInfo!.isNewUser) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('uid', FirebaseAuth.instance.currentUser!.uid);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const SignupPage(authProvider: 'google')));
      } else {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        prefs.setString('uid', FirebaseAuth.instance.currentUser!.uid);
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => const SplashScreen()));
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              const Image(
                image: AssetImage("assets/images/logo.webp"),
                width: 200,
                height: 200,
              ),
              const SizedBox(height: 16),
              const Text(
                "Login",
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Color.fromRGBO(236, 187, 32, 1),
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              TextFieldWidget(
                text: 'Email',
                controller: _emailTextController,
                isPassword: false,
                typeNumber: false,
                maxLine: false,
              ),
              const SizedBox(height: 16),
              TextFieldWidget(
                text: 'Password',
                controller: _passwordTextController,
                isPassword: true,
                typeNumber: false,
                maxLine: false,
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ResetPassword()));
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          color: Color.fromRGBO(236, 187, 32, 1)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    FirebaseAuth.instance
                        .signInWithEmailAndPassword(
                            email: _emailTextController.text,
                            password: _passwordTextController.text)
                        .then((value) async {
                      SharedPreferences prefs =
                          await SharedPreferences.getInstance();
                      User? user = value.user;
                      prefs.setString('uid', user!.uid);

                      Navigator.push(
                          // ignore: use_build_context_synchronously
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SplashScreen()));
                    }).onError((error, stackTrace) {
                      showDialog(

                          // ignore: use_build_context_synchronously
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor:
                                  const Color.fromARGB(255, 21, 21, 21),
                              title: const Text('Invalid Password or Email Id',
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 255, 255, 255),
                                  )),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'Okay!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                      color: Color.fromRGBO(236, 187, 32, 1),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          });
                    });
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
                            "Login",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                fontSize: 26),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    icon: Image.network(
                        'https://cdn4.iconfinder.com/data/icons/logos-brands-7/512/google_logo-google_icongoogle-512.png',
                        height: 26),
                    label: const Text('Sign in with Google',
                        style: TextStyle(fontFamily: "Poppins", fontSize: 18)),
                    onPressed: googleSignIn),
              ),
              const SizedBox(
                height: 16,
              ),
              const Text("- Create an account -",
                  style: TextStyle(
                      fontFamily: "Poppins",
                      color: Colors.white,
                      fontSize: 18)),
              const SizedBox(height: 16),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SignupPage(authProvider: 'email')));
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50),
                    color: const Color.fromRGBO(236, 187, 32, 1),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                    child: Text(
                      "SignUp",
                      style: TextStyle(
                          fontFamily: "Poppins",
                          fontWeight: FontWeight.w600,
                          fontSize: 26),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      )),
    );
  }
}

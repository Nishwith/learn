import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:learn/Screens/home_page.dart';
import 'package:learn/Screens/splash_screen.dart';
import 'package:learn/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupPage extends StatefulWidget {
  final String authProvider;
  const SignupPage({super.key, required this.authProvider});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  late bool isGoogleProvider;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fullNameTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _phoneNumberTextController =
      TextEditingController();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _confirmPasswordTextController =
      TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    isGoogleProvider = isGoogleProviderFunc();
  }

  isGoogleProviderFunc() {
    if (widget.authProvider == 'google') {
      _emailTextController.text = user!.email!;
      return true;
    } else {
      return false;
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  bool isLoading = false;
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
        String? email = userCredential.user?.email;
        print(email);
        // ignore: use_build_context_synchronously
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    const SignupPage(authProvider: 'google')));
      } else {
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
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 16,
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image(
                    image: AssetImage("assets/images/logo.webp"),
                    width: 100,
                    height: 100,
                  ),
                  SizedBox(width: 40),
                  Text(
                    "Sign Up",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(236, 187, 32, 1),
                        fontFamily: "Poppins",
                        fontSize: 40),
                  ),
                ],
              ),
              const SizedBox(
                height: 16,
              ),
              TextFieldWidget(
                text: 'Full Name',
                controller: _fullNameTextController,
                isPassword: false,
                typeNumber: false,
              ),
              const SizedBox(
                height: 16,
              ),
              if (!isGoogleProvider)
                TextFieldWidget(
                  text: 'Email',
                  controller: _emailTextController,
                  isPassword: false,
                  typeNumber: false,
                ),
              const SizedBox(
                height: 16,
              ),
              TextFieldWidget(
                text: 'Phone Number',
                controller: _phoneNumberTextController,
                isPassword: false,
                typeNumber: true,
              ),
              const SizedBox(
                height: 16,
              ),
              if (!isGoogleProvider)
                Column(
                  children: [
                    TextFieldWidget(
                      text: 'Password',
                      controller: _passwordTextController,
                      isPassword: true,
                      typeNumber: false,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    TextFieldWidget(
                      text: 'Confirm Password',
                      controller: _confirmPasswordTextController,
                      isPassword: true,
                      typeNumber: false,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                  ],
                ),
              InkWell(
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      isLoading = true;
                    });
                    if (isGoogleProvider) {
                      if (_phoneNumberTextController.text.length != 10) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor:
                                    const Color.fromARGB(255, 21, 21, 21),
                                title: const Text(
                                    'Please Enter Valid Phone Number!',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Okay',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          color:
                                              Color.fromRGBO(236, 187, 32, 1)),
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else {
                        try {
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser?.uid)
                              .set({
                            'phoneNum': _phoneNumberTextController.text,
                            'email': _emailTextController.text,
                            'Full Name': _fullNameTextController.text,
                            'Registration': "pending"
                          });
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString(
                              'uid', FirebaseAuth.instance.currentUser!.uid);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SplashScreen()));
                        } catch (error) {
                          return;
                        }
                      }
                    } else {
                      if (_phoneNumberTextController.text.length != 10) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor:
                                    const Color.fromARGB(255, 21, 21, 21),
                                title: const Text(
                                    'Please Enter Valid Phone Number!',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Okay',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          color:
                                              Color.fromRGBO(236, 187, 32, 1)),
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                          .hasMatch(_emailTextController.text)) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor:
                                    const Color.fromARGB(255, 21, 21, 21),
                                title:
                                    const Text('Please Enter Valid Email ID!',
                                        style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        )),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Okay',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          color:
                                              Color.fromRGBO(236, 187, 32, 1)),
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else if (_passwordTextController.text.length < 8) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor:
                                    const Color.fromARGB(255, 21, 21, 21),
                                title: const Text(
                                    'Password should be storng and atleast 8 characters!',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Okay',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          color:
                                              Color.fromRGBO(236, 187, 32, 1)),
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else if (_passwordTextController.text !=
                          _confirmPasswordTextController.text) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor:
                                    const Color.fromARGB(255, 21, 21, 21),
                                title: const Text('Passwords do not match !!',
                                    style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    )),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'Okay',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15.0,
                                          color:
                                              Color.fromRGBO(236, 187, 32, 1)),
                                    ),
                                  ),
                                ],
                              );
                            });
                      } else {
                        try {
                          final FirebaseAuth auth = FirebaseAuth.instance;
                          UserCredential userCredential =
                              await auth.createUserWithEmailAndPassword(
                            email: _emailTextController.text.trim(),
                            password: _passwordTextController.text.trim(),
                          );
                          User? user = userCredential.user;
                          FirebaseFirestore.instance
                              .collection('users')
                              .doc(user!.uid)
                              .set({
                            'phoneNum': _phoneNumberTextController.text,
                            'email': _emailTextController.text,
                            'Full Name': _fullNameTextController.text,
                            'Registration': "pending"
                          });
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          prefs.setString('uid', user.uid);
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SplashScreen()));
                        } catch (error) {
                          return;
                        }
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                  }
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
                            "SignUp",
                            style: TextStyle(
                                fontFamily: "Poppins",
                                fontWeight: FontWeight.w600,
                                fontSize: 26),
                          ),
                  ),
                ),
              ),
              if (!isGoogleProvider)
                Column(
                  children: [
                    const SizedBox(
                      height: 16,
                    ),
                    const Text("- or -",
                        style: TextStyle(
                            fontFamily: "Poppins",
                            color: Colors.white,
                            fontSize: 18)),
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
                        label: const Text('Sign up with Google',
                            style:
                                TextStyle(fontFamily: "Poppins", fontSize: 18)),
                        onPressed: () async {
                          googleSignIn();
                        },
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

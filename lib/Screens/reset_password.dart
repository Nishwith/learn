import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/Screens/login_page.dart';
import 'package:learn/utilities.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final TextEditingController _emailTextController = TextEditingController();
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 26,
              color: Color.fromRGBO(236, 187, 32, 1),
            )),
        title: const Text('Reset Password'),
        titleTextStyle: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            fontFamily: "Poppins",
            color: Color.fromRGBO(236, 187, 32, 1)),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          TextFieldWidget(
            text: 'Email',
            controller: _emailTextController,
            isPassword: false,
            typeNumber: false,
          ),
          const SizedBox(
            height: 40,
          ),
          InkWell(
            onTap: () {
              _resetPassword(context);
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: const Color.fromRGBO(236, 187, 32, 1),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                child: Text(
                  "Reset",
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
    );
  }

  Future<void> _resetPassword(BuildContext context) async {
    try {
      setState(() {
        isLoading = true;
      });
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailTextController.text);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Password reset email sent successfully! Check your Mail.'),
          duration: Duration(seconds: 3),
        ),
      );
      // ignore: use_build_context_synchronously
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const LoginPage()));
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User Not Found!'),
          duration: Duration(seconds: 3),
        ),
      );
      setState(() {
        isLoading = false;
      });
    }
  }
}

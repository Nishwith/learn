import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/utilities.dart';

class AddGigPage extends StatefulWidget {
  const AddGigPage({super.key});

  @override
  State<AddGigPage> createState() => _AddGigPageState();
}

class _AddGigPageState extends State<AddGigPage> {
  final _formKey = GlobalKey<FormState>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool isLoading = false;
  final TextEditingController _skillNameController = TextEditingController();
  final TextEditingController _courseAmountController = TextEditingController();
  final TextEditingController _exchangeSkillController =
      TextEditingController();
  final TextEditingController _portfolioLinkController =
      TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _courseContentController =
      TextEditingController();
  bool _status = false;
  bool _certificate = false;

  Future<String?> _uploadImage() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    try {
      final ref = await _firestore.collection("users").doc(userUid).get();
      final userData = ref.data();
      if (userData != null && userData.containsKey('userImg')) {
        return userData['userImg'] as String;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<String?> _userName() async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    try {
      final ref = await _firestore.collection("users").doc(userUid).get();
      final userData = ref.data();
      if (userData != null && userData.containsKey('Full Name')) {
        return userData['Full Name'] as String;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill in all fields and upload an image.')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid == null) return;
    String? userName = await _userName();
    String? imageUrl = await _uploadImage();
    String generateRandomString(int length) {
      const characters =
          'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final random = Random();
      return List.generate(
              length, (index) => characters[random.nextInt(characters.length)])
          .join();
    }

    final gigId = generateRandomString(10);
    final gigData = {
      'skillName': _skillNameController.text,
      'courseAmount': _courseAmountController.text,
      'exchangeSkill': _exchangeSkillController.text,
      'name': userName,
      'gigId': gigId,
      'portfolioLink': _portfolioLinkController.text,
      'description': _descriptionController.text,
      'courseContent': _courseContentController.text,
      'status': _status,
      'courseCertificate': _certificate,
      'imageUrl': imageUrl,
      'userUid': userUid,
    };

    try {
      // Save to both locations
      await _firestore.collection('gigs').doc().set(gigData);
      await _firestore
          .collection('users')
          .doc(userUid)
          .collection('gigs')
          .doc()
          .set(gigData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gig successfully added.')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error saving gig data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error saving gig data. Please try again.')),
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Gig"),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  text: "Skill you teach",
                  controller: _skillNameController,
                  isPassword: false,
                  typeNumber: false,
                  maxLine: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  text: "Portfolio",
                  controller: _portfolioLinkController,
                  isPassword: false,
                  typeNumber: false,
                  maxLine: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  text: "Description",
                  controller: _descriptionController,
                  isPassword: false,
                  typeNumber: false,
                  maxLine: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  text: "Course Contents",
                  controller: _courseContentController,
                  isPassword: false,
                  typeNumber: false,
                  maxLine: true,
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextFormField(
                    controller: _exchangeSkillController,
                    cursorColor: const Color.fromRGBO(236, 187, 32, 1),
                    decoration: const InputDecoration(
                      hintText: "Skill Required in Exchange.",
                      labelText: "Skill Required in Exchange.",
                      hintStyle: TextStyle(
                        fontFamily: "Poppins",
                      ),
                      labelStyle: TextStyle(
                        fontFamily: "Poppins",
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(236, 187, 32, 1),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                      ),
                      fillColor: Color.fromARGB(21, 217, 217, 217),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(50)),
                        borderSide: BorderSide(
                          color: Color.fromRGBO(236, 187, 32, 1),
                        ),
                      ),
                      filled: true,
                    ),
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFieldWidget(
                  text: "Course Amount (if not - 0).",
                  controller: _courseAmountController,
                  isPassword: false,
                  typeNumber: true,
                  maxLine: false,
                ),
                const SizedBox(
                  height: 10,
                ),
                SwitchListTile(
                  title: const Text(
                    'Status',
                    style: TextStyle(
                      color: Color.fromRGBO(236, 187, 32, 1),
                    ),
                  ),
                  value: _status,
                  activeColor: const Color.fromRGBO(236, 187, 32, 1),
                  onChanged: (value) {
                    setState(() {
                      _status = value;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                SwitchListTile(
                  title: const Text(
                    'Do you provide certificate',
                    style: TextStyle(
                      color: Color.fromRGBO(236, 187, 32, 1),
                    ),
                  ),
                  value: _certificate,
                  activeColor: const Color.fromRGBO(236, 187, 32, 1),
                  onChanged: (value) {
                    setState(() {
                      _certificate = value;
                    });
                  },
                ),
                InkWell(
                  onTap: _submitForm,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color.fromRGBO(236, 187, 32, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 30),
                      child: isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : const Text(
                              "Submit",
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 26),
                            ),
                    ),
                  ),
                ),
              ],
            )),
      ),
    );
  }
}

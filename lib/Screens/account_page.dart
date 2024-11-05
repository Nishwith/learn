import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/Screens/edit_account.dart';
import 'package:learn/utilities.dart';
import 'package:url_launcher/link.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Map<String, dynamic> userData = {};
  List<Map<String, dynamic>> skills = [];
  List<String> skillsToLearn = [];
  String? id;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    if (userId == null) return;

    try {
      // Fetch main user data from 'users' collection
      final userDoc = await _firestore.collection('users').doc(userId).get();
      userData = userDoc.data() ?? {};

      // Fetch the registration subcollection document
      final regSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('registration')
          .get();

      if (regSnapshot.docs.isNotEmpty) {
        final regData = regSnapshot.docs.first.data();
        id = regSnapshot.docs.first.id;
        userData['profession'] = regData['profession'] ?? '';
        skills = List<Map<String, dynamic>>.from(regData['skills'] ?? []);
        skillsToLearn = List<String>.from(regData['skillsToLearn'] ?? []);
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "Profile"),
      drawer: CustomDrawer(),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(
                left: 10, top: 10, right: 10, bottom: 100),
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                decoration: const BoxDecoration(
                  color: Color.fromARGB(16, 255, 255, 255),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                margin: const EdgeInsets.only(top: 30),
                padding: const EdgeInsets.only(
                    left: 10, top: 10, right: 10, bottom: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userData['userImg'] != null
                          ? NetworkImage(userData['userImg'])
                          : const AssetImage('assets/images/avatar2.jpg'),
                    ),
                    const SizedBox(height: 10),

                    // User Name
                    Text(
                      userData['Full Name'] ?? 'Name not available',
                      style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'poppins',
                          color: Colors.white),
                    ),

                    const SizedBox(height: 10),
                    // Profession
                    Text(
                      userData['profession'] ?? 'Profession not available',
                      style: const TextStyle(
                        fontSize: 18,
                        fontFamily: 'poppins',
                        color: Color.fromRGBO(236, 187, 32, 1),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          userData['email'] ?? '',
                          style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'poppins',
                              color: Colors.white),
                        ),
                        const Text(
                          ' | ',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'poppins',
                              color: Colors.white),
                        ),
                        Text(
                          userData['phoneNum'] ?? '',
                          style: const TextStyle(
                              fontSize: 18,
                              fontFamily: 'poppins',
                              color: Colors.white),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                    const SizedBox(height: 20),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Skills:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(236, 187, 32, 1),
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...skills.map((skill) => ListTile(
                          title: Text(
                            skill['skillName'] ?? 'N/A',
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'poppins',
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Experience: ${skill['experience']} years",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'poppins',
                                ),
                              ),
                              Text(
                                "Skill Level: ${skill['skillLevel']}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontFamily: 'poppins',
                                ),
                              ),
                              Link(
                                  uri: Uri.parse(skill['portfolio'] ??
                                      "https://flutter.dev"),
                                  target: LinkTarget
                                      .blank, // Open in new tab if possible
                                  builder: (context, followLink) =>
                                      GestureDetector(
                                        onTap: followLink,
                                        child: Text(
                                          skill['portfolio'],
                                          style: const TextStyle(
                                            color:
                                                Color.fromRGBO(236, 187, 32, 1),
                                            fontFamily: "poppins",
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor:
                                                Color.fromRGBO(236, 187, 32, 1),
                                            fontSize: 18,
                                          ),
                                        ),
                                      )),
                              const Divider(
                                color: Colors.white,
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 20),

                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Skills to Learn:',
                        style: TextStyle(
                          fontSize: 20,
                          color: Color.fromRGBO(236, 187, 32, 1),
                          fontFamily: 'poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    ...skillsToLearn.map((skill) => ListTile(
                          title: Text(
                            skill,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontFamily: 'poppins',
                            ),
                          ),
                        )),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditAccountPage(
                                  userData: userData,
                                  id: id!,
                                  skills: skills,
                                  skillsToLearn: skillsToLearn)),
                        );
                      },
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: const Color.fromRGBO(236, 187, 32, 1),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 30),
                            child: Text(
                              "Edit",
                              style: TextStyle(
                                  fontFamily: "Poppins",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 26),
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
          BottomNavBar(pageIndex: 4),
        ],
      ),
    );
  }
}

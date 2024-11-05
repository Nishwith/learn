import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/Screens/waiting_page.dart';
import 'package:learn/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _skillLearnController = TextEditingController();
  final List<SkillField> skillFields = [
    const SkillField()
  ]; // Initialize with one set of skill fields

  final List<String> profession = [
    'Student',
    'Employee',
    'Freelancer',
  ];
  String? selectedProfession;

  final List<String> skillLevel = [
    'Beginner',
    'Intermediate',
    'Advance',
  ];
  bool isLoading = false;
  final List<GlobalKey<_SkillFieldState>> skillFieldKeys = [
    GlobalKey<_SkillFieldState>() // Initialize with one key
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
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
                    "Register",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color.fromRGBO(236, 187, 32, 1),
                        fontFamily: "Poppins",
                        fontSize: 40),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              // Profession Dropdown
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(21, 217, 217, 217),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(
                    color: const Color.fromRGBO(236, 187, 32, 1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                    isExpanded: true,
                    hint: const Text(
                      'Select your Profession',
                      style: TextStyle(
                        fontFamily: "Poppins",
                        color: Color.fromRGBO(255, 255, 255, 1),
                      ),
                    ),
                    value: selectedProfession,
                    dropdownColor: const Color.fromRGBO(21, 21, 21, 1),
                    iconEnabledColor: const Color.fromRGBO(236, 187, 32, 1),
                    items: profession.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                            fontFamily: "Poppins",
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontSize: 20,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedProfession = newValue;
                      });
                    },
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              // List of Skill Fields
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: skillFields.length,
                itemBuilder: (context, index) {
                  return SkillField(key: skillFieldKeys[index]);
                },
              ),
              const SizedBox(height: 10),
              // Button to Add More Skills
              InkWell(
                onTap: () {
                  setState(() {
                    skillFieldKeys.add(GlobalKey<_SkillFieldState>());
                    skillFields.add(const SkillField());
                  });
                },
                child: const Text(
                  "+ add 1 more skill",
                  style: TextStyle(
                      color: Color(0xFF1E90FF),
                      fontFamily: "poppins",
                      fontSize: 20),
                ),
              ),
              const SizedBox(
                height: 10,
              ),

              TextFieldWidget(
                text: 'Skills to Learn (e.g. editing, designing)',
                controller: _skillLearnController,
                isPassword: false,
                typeNumber: false,
                maxLine: false,
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                onTap: register,
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
                            "Register",
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
      ),
    );
  }

  Future<void> register() async {
    // Collecting data from the input fields
    String skillsToLearn = _skillLearnController.text;
    String profession = selectedProfession ?? '';
    List<Map<String, dynamic>> skillsData = [];

    for (var key in skillFieldKeys) {
      var skillState = key.currentState; // Get the current state
      if (skillState != null) {
        skillsData.add({
          'skillName': skillState._skillNameTextController.text,
          'experience': skillState._experienceTextController.text,
          'portfolio': skillState._portfolioTextController.text,
          'skillLevel': skillState.selectedSkillLevel,
        });
      }
    }

    // Simple validation example
    if (profession.isEmpty || skillsData.isEmpty || skillsToLearn.isEmpty) {
      // Show an error message (e.g., using a SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            margin: EdgeInsets.all(20),
            behavior: SnackBarBehavior.floating,
            content: Text('Please fill in all fields')),
      );
      return; // Exit if validation fails
    }

    // Set loading state
    setState(() {
      isLoading = true;
    });

    try {
      // Get user UID (assuming you're using Firebase Authentication)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var uid = prefs.getString('uid');
      // Create a reference to the Firestore collection
      final userDocument =
          FirebaseFirestore.instance.collection('users').doc(uid);

      // Create a sub-collection 'registration' for the user
      final registrationCollection = userDocument.collection('registration');
      List<String> skillsToLearnArray =
          skillsToLearn.split(',').map((skill) => skill.trim()).toList();
      // Create a document for the user with their UID
      await registrationCollection.add({
        'profession': profession,
        'skillsToLearn': skillsToLearnArray,
        'skills': skillsData,
      });
      await userDocument.update({
        'Registration': 'waiting', // Set the registration field to 'waiting'
      });
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            margin: EdgeInsets.all(20),
            behavior: SnackBarBehavior.floating,
            content: Text('Registration Successful!')),
      );

      // Clear fields or navigate to another screen if needed
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const WaitingPage()));
    } catch (e) {
      // Handle errors appropriately
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            margin: EdgeInsets.all(20),
            behavior: SnackBarBehavior.floating,
            content: Text('Registration Failed. Please try again.')),
      );
    } finally {
      // Reset loading state
      setState(() {
        isLoading = false;
      });
    }
  }
}

// Skill Field Widget
class SkillField extends StatefulWidget {
  const SkillField({super.key}); // Pass the key to the superclass

  @override
  _SkillFieldState createState() => _SkillFieldState();
}

class _SkillFieldState extends State<SkillField> {
  final TextEditingController _skillNameTextController =
      TextEditingController();
  final TextEditingController _experienceTextController =
      TextEditingController();
  final TextEditingController _portfolioTextController =
      TextEditingController();
  String? selectedSkillLevel;

  final List<String> skillLevel = [
    'Beginner',
    'Intermediate',
    'Advance',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Skill:",
              style: TextStyle(
                  color: Colors.white, fontFamily: "poppins", fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextFieldWidget(
          text: 'Skill Name',
          controller: _skillNameTextController,
          isPassword: false,
          typeNumber: false,
          maxLine: false,
        ),
        const SizedBox(height: 10),
        TextFieldWidget(
          text: 'Years of Experience',
          controller: _experienceTextController,
          isPassword: false,
          typeNumber: true,
          maxLine: false,
        ),
        const SizedBox(height: 10),
        TextFieldWidget(
          text: 'Portfolio Link',
          controller: _portfolioTextController,
          isPassword: false,
          typeNumber: false,
          maxLine: false,
        ),
        const SizedBox(height: 10),
        // Skill Level Dropdown
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: const Color.fromARGB(21, 217, 217, 217),
            borderRadius: BorderRadius.circular(50),
            border: Border.all(
              color: const Color.fromRGBO(236, 187, 32, 1),
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              isExpanded: true,
              hint: const Text(
                'Skill Level',
                style: TextStyle(
                  fontFamily: "Poppins",
                  color: Color.fromRGBO(255, 255, 255, 1),
                ),
              ),
              value: selectedSkillLevel,
              dropdownColor: const Color.fromRGBO(21, 21, 21, 1),
              iconEnabledColor: const Color.fromRGBO(236, 187, 32, 1),
              items: skillLevel.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 20,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedSkillLevel = newValue;
                });
              },
              style: const TextStyle(
                fontFamily: "Poppins",
                color: Color.fromRGBO(255, 255, 255, 1),
                fontSize: 20,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }
}

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:learn/Screens/account_page.dart';
import 'package:learn/utilities.dart';

class EditAccountPage extends StatefulWidget {
  final Map<String, dynamic> userData;
  final List<Map<String, dynamic>> skills;
  final List<String> skillsToLearn;
  final String id;

  const EditAccountPage({
    super.key,
    required this.userData,
    required this.skills,
    required this.skillsToLearn,
    required this.id,
  });

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  final List<String> profession = [
    'Student',
    'Employee',
    'Freelancer',
  ];
  String? selectedProfession;
  String? selectedSkillLevel;
  final List<String> skillLevel = [
    'Beginner',
    'Intermediate',
    'Advance',
  ];
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumController;
  late TextEditingController _newSkillNameController;
  late TextEditingController _newSkillExperienceController;
  late TextEditingController _newSkillPortfolioController;
  late TextEditingController _newSkillToLearnController;
  final userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> skills = [];
  List<String> skillsToLearn = [];
  File? _selectedImage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.userData['Full Name']);
    _emailController = TextEditingController(text: widget.userData['email']);
    _phoneNumController =
        TextEditingController(text: widget.userData['phoneNum']);
    selectedProfession = widget.userData['profession'];
    _newSkillNameController = TextEditingController();
    _newSkillExperienceController = TextEditingController();
    _newSkillPortfolioController = TextEditingController();
    _newSkillToLearnController = TextEditingController();
    skills = List.from(widget.skills);
    skillsToLearn = List.from(widget.skillsToLearn);
  }

  String? downloadUrl;
  Future<void> uploadProfileImage() async {
    if (userId == null) return;

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return;

    File imageFile = File(pickedFile.path);

    try {
      // Define a storage reference
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('$userId.jpg');

      // Upload the file
      await storageRef.putFile(imageFile);

      // Retrieve the download URL
      downloadUrl = await storageRef.getDownloadURL();

      // Update local data and UI
      setState(() {
        widget.userData['userImg'] = downloadUrl;
      });
    } catch (e) {
      print("Error uploading image: $e");
    }
  }

  void _addNewSkill() {
    if (_newSkillNameController.text.isNotEmpty) {
      setState(() {
        skills.add({
          'skillName': _newSkillNameController.text,
          'experience': _newSkillExperienceController.text,
          'skillLevel': selectedSkillLevel,
          'portfolio': _newSkillPortfolioController.text,
        });
      });

      // Clear the input fields
      _newSkillNameController.clear();
      _newSkillExperienceController.clear();
      _newSkillPortfolioController.clear();
    }
  }

  void _addSkillToLearn() {
    if (_newSkillToLearnController.text.isNotEmpty) {
      setState(() {
        skillsToLearn.addAll(_newSkillToLearnController.text
            .split(',')
            .map((skill) => skill.trim())
            .where((skill) => skill.isNotEmpty));
      });
      _newSkillToLearnController.clear();
    }
  }

  Future<void> _saveProfileChanges() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    // Update Firestore with the edited data
    await _firestore.collection('users').doc(userId).update({
      'Full Name': _nameController.text,
      'email': _emailController.text,
      'phoneNum': _phoneNumController.text,
      'userImg': downloadUrl ?? widget.userData['userImg'],
    });

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('registration')
        .doc(widget.id)
        .update({
      'profession': selectedProfession,
      'skills': skills,
      'skillsToLearn': skillsToLearn,
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const AccountPage())); // Return to AccountPage after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Edit Profile"),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile Image
            Center(
              child: GestureDetector(
                onTap: uploadProfileImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (widget.userData['userImg'] != null
                              ? NetworkImage(widget.userData['userImg'])
                              : const AssetImage('assets/images/avatar2.jpg'))
                          as ImageProvider,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Text Fields for Basic Information
            TextFieldWidget(
              controller: _nameController,
              text: 'Full Name',
              isPassword: false,
              typeNumber: false,
              maxLine: false,
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              controller: _emailController,
              text: 'Email',
              isPassword: false,
              typeNumber: false,
              maxLine: false,
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              controller: _phoneNumController,
              text: 'Phone Number',
              isPassword: false,
              typeNumber: false,
              maxLine: false,
            ),
            const SizedBox(height: 10),

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

            const SizedBox(height: 20),
            const Text(
              'Add New Skill',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              controller: _newSkillNameController,
              text: 'Skill Name',
              isPassword: false,
              typeNumber: false,
              maxLine: false,
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              controller: _newSkillExperienceController,
              text: 'Experience (in years)',
              isPassword: false,
              typeNumber: true,
              maxLine: false,
            ),
            const SizedBox(height: 10),

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

            TextFieldWidget(
              text: 'Portfolio Link',
              controller: _newSkillPortfolioController,
              isPassword: false,
              typeNumber: false,
              maxLine: false,
            ),
            const SizedBox(height: 10),
            InkWell(
                onTap: _addNewSkill,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color.fromRGBO(236, 187, 32, 1),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                      child: Text(
                        'Add Skill',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ))),
            const SizedBox(height: 10),
            const Divider(),

            const SizedBox(height: 20),
            const Text(
              'Add New Skill to Learn',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            TextFieldWidget(
              text: 'Skills to Learn (e.g. editing, designing)',
              controller: _newSkillToLearnController,
              isPassword: false,
              typeNumber: false,
              maxLine: false,
            ),
            const SizedBox(height: 10),
            InkWell(
                onTap: _addSkillToLearn,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color.fromRGBO(236, 187, 32, 1),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                      child: Text(
                        'Add Skill to Learn',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ))),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            InkWell(
                onTap: _saveProfileChanges,
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      color: const Color.fromRGBO(236, 187, 32, 1),
                    ),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(vertical: 6, horizontal: 30),
                      child: Text(
                        'Save changes',
                        style: TextStyle(
                            color: Colors.black,
                            fontFamily: "Poppins",
                            fontWeight: FontWeight.w600,
                            fontSize: 20),
                      ),
                    ))),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/utilities.dart';

class EditGigPage extends StatefulWidget {
  final Map<dynamic, dynamic> gigData;
  final dynamic docId;

  const EditGigPage({super.key, required this.gigData, required this.docId});

  @override
  State<EditGigPage> createState() => _EditGigPageState();
}

class _EditGigPageState extends State<EditGigPage> {
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
  String? gigId;

  @override
  void initState() {
    super.initState();
    // Initialize controllers with existing data
    _skillNameController.text = widget.gigData['skillName'] ?? '';
    _courseAmountController.text = widget.gigData['courseAmount'] ?? '';
    _exchangeSkillController.text = widget.gigData['exchangeSkill'] ?? '';
    _portfolioLinkController.text = widget.gigData['portfolioLink'] ?? '';
    _descriptionController.text = widget.gigData['description'] ?? '';
    _courseContentController.text = widget.gigData['courseContent'] ?? '';
    _status = widget.gigData['status'] ?? false;
    _certificate = widget.gigData['courseCertificate'] ?? false;
    gigId = widget.gigData['gigId'] ?? '';
  }

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

    final gigData = {
      'skillName': _skillNameController.text,
      'courseAmount': _courseAmountController.text,
      'exchangeSkill': _exchangeSkillController.text,
      'name': userName,
      'portfolioLink': _portfolioLinkController.text,
      'description': _descriptionController.text,
      'courseContent': _courseContentController.text,
      'status': _status,
      'courseCertificate': _certificate,
      'imageUrl': imageUrl,
      'userUid': userUid,
    };

    try {
      // Update the existing gig in the gigs collection
      // Update the gig in the main 'gigs' collection
      await _firestore
          .collection('gigs')
          .where('gigId', isEqualTo: gigId)
          .get()
          .then((snapshot) async {
        for (var doc in snapshot.docs) {
          await doc.reference.update(gigData);
        }
      });

      await _firestore
          .collection('users')
          .doc(userUid)
          .collection('gigs')
          .where('gigId', isEqualTo: gigId)
          .get()
          .then((snapshot) async {
        for (var doc in snapshot.docs) {
          await doc.reference.update(gigData);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gig successfully updated.')),
      );
      Navigator.pop(context); // Optionally close the form after submission
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
      appBar: const CustomAppBar(title: "Edit Gig"),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              TextFieldWidget(
                text: "Skill you teach",
                controller: _skillNameController,
                isPassword: false,
                typeNumber: false,
                maxLine: false,
              ),
              const SizedBox(height: 10),
              TextFieldWidget(
                text: "Portfolio",
                controller: _portfolioLinkController,
                isPassword: false,
                typeNumber: false,
                maxLine: false,
              ),
              const SizedBox(height: 10),
              TextFieldWidget(
                text: "Description",
                controller: _descriptionController,
                isPassword: false,
                typeNumber: false,
                maxLine: true,
              ),
              const SizedBox(height: 10),
              TextFieldWidget(
                text: "Course Contents",
                controller: _courseContentController,
                isPassword: false,
                typeNumber: false,
                maxLine: true,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              TextFieldWidget(
                text: "Course Amount (if not - 0).",
                controller: _courseAmountController,
                isPassword: false,
                typeNumber: true,
                maxLine: false,
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
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
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromRGBO(236, 187, 32, 1),
                        Color.fromRGBO(197, 149, 37, 1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  height: 50,
                  width: MediaQuery.of(context).size.width * 0.75,
                  child: Center(
                    child: isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                          )
                        : const Text(
                            'Update',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontFamily: 'Poppins',
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

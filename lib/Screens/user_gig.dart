import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/Screens/home_page.dart';
import 'package:learn/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/link.dart';

class UserGigPage extends StatefulWidget {
  final dynamic gigData;
  final dynamic docId;

  const UserGigPage({super.key, required this.gigData, required this.docId});

  @override
  State<UserGigPage> createState() => _UserGigPageState();
}

class _UserGigPageState extends State<UserGigPage> {
  bool hasRequested = false;

  @override
  void initState() {
    super.initState();
    getUserUid();
  }

  Future<void> getUserUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userUid = prefs.getString("uid");
    String tutorUid = widget.docId;

    if (userUid != null) {
      await checkIfAlreadyRequested(userUid, tutorUid);
    }
  }

  Future<void> checkIfAlreadyRequested(String userUid, String tutorUid) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(tutorUid)
        .collection('chats')
        .where('requesterId', isEqualTo: userUid)
        .get();

    setState(() {
      hasRequested = querySnapshot.docs.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    final getUserUid = FirebaseAuth.instance.currentUser?.uid;
    print(getUserUid);
    bool isportfolio() {
      if (widget.gigData["portfolioLink"] == null &&
          widget.gigData["portfolioLink"] == "null" &&
          widget.gigData["portfolioLink"] == '') {
        return true;
      } else {
        return false;
      }
    }

    bool portfolio = isportfolio();

    final String? courseAmount = widget.gigData["courseAmount"]?.toString();
    final String? exchangeSkill = widget.gigData["exchangeSkill"];

    bool num = false;

    if (courseAmount != null && courseAmount != "null" && courseAmount != "0") {
      num = true;
    }
    String courseOutlineString =
        widget.gigData["courseContent"] ?? "No outline";
    List<String> courseOutline = courseOutlineString
        .split("  ") // Split by double spaces
        .map((item) => item.trim()) // Trim whitespace from each item
        .where((item) => item.isNotEmpty) // Filter out any empty strings
        .cast<String>() // Cast to List<String>
        .toList();
    certificate() {
      if (widget.gigData["status"] == true) {
        return "Certificate will be provided";
      } else {
        return "Certificate will not be provided";
      }
    }

    return Scaffold(
      appBar: const CustomAppBar(title: "LEarn"),
      drawer: CustomDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(10), // Optional padding
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
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipOval(
                  child: Image(
                    image: NetworkImage(widget.gigData["imageUrl"]),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.red,
                        size: 50,
                      ); // Fallback if image fails to load
                    },
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  capitalizeFirstLetter(
                      widget.gigData["name"] ?? "Unknown Name"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontFamily: "poppins",
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  capitalizeFirstLetter(
                      widget.gigData["skillName"] ?? "No Skill"),
                  style: const TextStyle(
                    color: Color.fromRGBO(236, 187, 32, 1),
                    fontWeight: FontWeight.w400,
                    fontFamily: "poppins",
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Description:",
                    style: TextStyle(
                      color: Color.fromRGBO(236, 187, 32, 1),
                      fontWeight: FontWeight.w500,
                      fontFamily: "poppins",
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  widget.gigData["description"] ?? "No Description",
                  style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontWeight: FontWeight.w400,
                    fontFamily: "poppins",
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 5),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Course Overview:",
                    style: TextStyle(
                      color: Color.fromRGBO(236, 187, 32, 1),
                      fontWeight: FontWeight.w500,
                      fontFamily: "poppins",
                      fontSize: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                // Display the course outline items as a list
                ...courseOutline.map(
                  (item) => Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(
                          item,
                          style: const TextStyle(
                            color: Color.fromRGBO(255, 255, 255, 1),
                            fontWeight: FontWeight.w400,
                            fontFamily: "poppins",
                            fontSize: 18,
                          ),
                        ),
                      )),
                ),
                const SizedBox(height: 5),
                if (portfolio)
                  Container()
                else
                  Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Portfolio:",
                          style: TextStyle(
                            color: Color.fromRGBO(236, 187, 32, 1),
                            fontWeight: FontWeight.w500,
                            fontFamily: "poppins",
                            fontSize: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Link(
                          uri: Uri.parse(widget.gigData["portfolioLink"] ??
                              "https://flutter.dev"),
                          target:
                              LinkTarget.blank, // Open in new tab if possible
                          builder: (context, followLink) => GestureDetector(
                                onTap: followLink,
                                child: const Text(
                                  "--Link--",
                                  style: TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "poppins",
                                    decoration: TextDecoration.underline,
                                    decorationColor:
                                        Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 18,
                                  ),
                                ),
                              )),
                    ],
                  ),
                const SizedBox(height: 5),
                const Divider(),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Course Certificate: ${capitalizeFirstLetter(certificate())}",
                    style: const TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontWeight: FontWeight.w400,
                      fontFamily: "poppins",
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    num
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              color: const Color.fromARGB(255, 255, 255, 255),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            child: Text(
                              '₹$courseAmount',
                              style: const TextStyle(
                                color: Color.fromRGBO(0, 0, 0, 1),
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                fontFamily: "Poppins",
                              ),
                            ),
                          )
                        : Container(),
                    // Check exchangeSkill only if it's valid
                    if (exchangeSkill != "null" &&
                        exchangeSkill != null &&
                        exchangeSkill.isNotEmpty)
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: const Color.fromRGBO(236, 187, 32, 1),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: Text(
                          capitalizeFirstLetter(exchangeSkill),
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                      )
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                if (getUserUid != null &&
                    getUserUid != widget.gigData["userUid"])
                  if (!hasRequested)
                    GestureDetector(
                      onTap: onTap,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                              color: const Color.fromRGBO(236, 187, 32, 1),
                              width: 2),
                          color: const Color.fromARGB(255, 0, 0, 0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        child: const Text(
                          "Request",
                          style: TextStyle(
                            color: Color.fromRGBO(236, 187, 32, 1),
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ),
                if (hasRequested)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(50),
                      border: Border.all(
                          color: const Color.fromRGBO(236, 187, 32, 1),
                          width: 2),
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    child: const Text(
                      "You sent a Request Already",
                      style: TextStyle(
                        color: Color.fromRGBO(236, 187, 32, 1),
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  onTap() {
    showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 21, 21, 21),
            title: Text(
                'Are you Really want to send the Request to ${capitalizeFirstLetter(widget.gigData["name"])} for ${capitalizeFirstLetter(widget.gigData["skillName"])}',
                style: const TextStyle(
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
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final String? courseAmount =
                      widget.gigData["courseAmount"]?.toString();
                  final String? exchangeSkill = widget.gigData["exchangeSkill"];
                  bool num = false;
                  if (courseAmount != null &&
                      courseAmount != "null" &&
                      courseAmount != "0") {
                    num = true;
                  }
                  showDialog(
                      // ignore: use_build_context_synchronously
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          backgroundColor:
                              const Color.fromARGB(255, 21, 21, 21),
                          title: Text(
                              'In what Exchage do you want to learn  ${capitalizeFirstLetter(widget.gigData["skillName"])} from ${capitalizeFirstLetter(widget.gigData["name"])}',
                              style: const TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 255, 255, 255),
                              )),
                          actions: [
                            TextButton(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? userUid = prefs.getString("uid");
                                String tutorUid = widget.docId;

                                try {
                                  var userNameDoc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(userUid)
                                      .get();
                                  print(userNameDoc);
                                  var userName = userNameDoc.data()
                                      as Map<String, dynamic>;
                                  DocumentReference requestDocRef =
                                      FirebaseFirestore.instance
                                          .collection('chats')
                                          .doc();

                                  // Set the document with the generated ID
                                  await requestDocRef.set({
                                    'requesterId': userUid,
                                    'TutorId': tutorUid,
                                    "tutorName": widget.gigData["name"],
                                    "requesterName": userName["Full Name"],
                                    'requestedSkill':
                                        widget.gigData["skillName"],
                                    'exchangeType': 'courseAmount',
                                    'courseAmount': '₹$courseAmount',
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'status': 'pending',
                                  });
                                  String requestDocId = requestDocRef.id;
                                  // Add a new document to the tutor's `requests` sub-collection
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(tutorUid)
                                      .collection('chats')
                                      .doc(requestDocId)
                                      .set({
                                    'requesterId': userUid,
                                    'TutorId': tutorUid,
                                    'chatId': requestDocId,
                                    "tutorName": widget.gigData["name"],
                                    "requesterName": userName["Full Name"],
                                    'requestedSkill':
                                        widget.gigData["skillName"],
                                    'exchangeType': 'courseAmount',
                                    'courseAmount': '₹$courseAmount',
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'status': 'pending',
                                  }, SetOptions(merge: true));

                                  // Update the requester's user document with the request information
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userUid)
                                      .collection('chats')
                                      .doc(requestDocId)
                                      .set({
                                    'TutorId': tutorUid,
                                    "tutorName": widget.gigData["name"],
                                    "requesterName": userName["Full Name"],
                                    'requestedSkill':
                                        widget.gigData["skillName"],
                                    'exchangeType': 'courseAmount',
                                    'chatId': requestDocId,
                                    'courseAmount': '₹$courseAmount',
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'status': 'pending',
                                  }, SetOptions(merge: true));

                                  // Optional: Show a confirmation message to the user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        margin: EdgeInsets.all(20),
                                        behavior: SnackBarBehavior.floating,
                                        content:
                                            Text("Request sent successfully!")),
                                  );
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePage()));
                                } catch (e) {
                                  print("Error sending request: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        margin: EdgeInsets.all(20),
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                            "Error sending request. Please try again.")),
                                  );
                                }
                              },
                              child: num
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: const Color.fromARGB(
                                            255, 255, 255, 255),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      child: Text(
                                        '₹$courseAmount',
                                        style: const TextStyle(
                                          color:
                                              Color.fromRGBO(236, 187, 32, 1),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                            TextButton(
                              onPressed: () async {
                                SharedPreferences prefs =
                                    await SharedPreferences.getInstance();
                                String? userUid = prefs.getString("uid");
                                String tutorUid = widget.docId;
                                try {
                                  var userNameDoc = await FirebaseFirestore
                                      .instance
                                      .collection('users')
                                      .doc(userUid)
                                      .get();
                                  var userName = userNameDoc.data()
                                      as Map<String, dynamic>;
                                  DocumentReference requestDocRef =
                                      FirebaseFirestore.instance
                                          .collection('chats')
                                          .doc();

                                  // Set the document with the generated ID
                                  String requestDocId = requestDocRef.id;
                                  await requestDocRef.set({
                                    'requesterId': userUid,
                                    'TutorId': tutorUid,
                                    "tutorName": widget.gigData["name"],
                                    "requesterName": userName["Full Name"],
                                    'requestedSkill':
                                        widget.gigData["skillName"],
                                    'exchangeType': 'skill',
                                    'exchangeSkill': exchangeSkill,
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'status': 'pending',
                                    'chatId': requestDocId,
                                  }, SetOptions(merge: true));

                                  // Get the document ID
                                  // Add a new document to the tutor's `requests` sub-collection
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(tutorUid)
                                      .collection('chats')
                                      .doc(requestDocId)
                                      .set({
                                    'requesterId': userUid,
                                    'TutorId': tutorUid,
                                    "tutorName": widget.gigData["name"],
                                    "requesterName": userName["Full Name"],
                                    'requestedSkill':
                                        widget.gigData["skillName"],
                                    'exchangeType': 'skill',
                                    'exchangeSkill': exchangeSkill,
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'status': 'pending',
                                    'chatId': requestDocId,
                                  }, SetOptions(merge: true));

                                  // Update the requester's user document with the request information
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userUid)
                                      .collection('chats')
                                      .doc(requestDocId)
                                      .set({
                                    'TutorId': tutorUid,
                                    "tutorName": widget.gigData["name"],
                                    "requesterName": userName["Full Name"],
                                    'requestedSkill':
                                        widget.gigData["skillName"],
                                    'exchangeType': 'skill',
                                    'exchangeSkill': exchangeSkill,
                                    'chatId': requestDocId,
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'status': 'pending',
                                  }, SetOptions(merge: true));

                                  // Optional: Show a confirmation message to the user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        margin: EdgeInsets.all(20),
                                        behavior: SnackBarBehavior.floating,
                                        content:
                                            Text("Request sent successfully!")),
                                  );
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HomePage()));
                                } catch (e) {
                                  print("Error sending request: $e");
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        margin: EdgeInsets.all(20),
                                        behavior: SnackBarBehavior.floating,
                                        content: Text(
                                            "Error sending request. Please try again.")),
                                  );
                                }
                              },
                              child: exchangeSkill != "null" &&
                                      exchangeSkill != null &&
                                      exchangeSkill.isNotEmpty
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(50),
                                        color: const Color.fromRGBO(
                                            236, 187, 32, 1),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 14, vertical: 6),
                                      child: Text(
                                        capitalizeFirstLetter(exchangeSkill),
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 0, 0, 0),
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Poppins",
                                        ),
                                      ),
                                    )
                                  : Container(),
                            ),
                          ],
                        );
                      });
                },
                child: const Text(
                  'Yes!!',
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
  }
}

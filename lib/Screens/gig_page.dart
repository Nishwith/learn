import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:learn/Screens/add_gig.dart';
import 'package:learn/Screens/edit_gig.dart';
import 'package:learn/utilities.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GigPage extends StatefulWidget {
  const GigPage({super.key});

  @override
  State<GigPage> createState() => _GigPageState();
}

class _GigPageState extends State<GigPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userUid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUid();
  }

  fetchUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userUid = prefs.getString("uid");

    if (userUid != null) {
      setState(() {
        isLoading = false; // Set loading to false once UID is fetched
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "Gigs"),
      drawer: CustomDrawer(),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(236, 187, 32, 1),
              ),
            )
          : Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const AddGigPage()));
                      },
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(16, 255, 255, 255),
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                        ),
                        margin: const EdgeInsets.all(10),
                        padding: const EdgeInsets.all(10),
                        child: const Center(
                          child: Text(
                            "+ Add one Gig",
                            style: TextStyle(
                              fontSize: 30,
                              color: Color.fromRGBO(236, 187, 32, 1),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore
                            .collection('users')
                            .doc(userUid)
                            .collection("gigs")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error fetching gigs'));
                          }

                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color.fromRGBO(236, 187, 32, 1),
                              ),
                            );
                          }

                          var gigDocs = snapshot.data?.docs;

                          if (gigDocs == null || gigDocs.isEmpty) {
                            return const Center(
                              child: Text(
                                'No gigs available',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromRGBO(236, 187, 32, 1),
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: gigDocs.length,
                            itemBuilder: (context, index) {
                              var gigData =
                                  gigDocs[index].data() as Map<String, dynamic>;
                              var docId = gigDocs[index].id;
                              var userId = gigDocs[index]["userUid"];
                              return GigCard(
                                  gigData: gigData, docId: userId, id: docId);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
                BottomNavBar(pageIndex: 1),
              ],
            ),
    );
  }
}

class GigCard extends StatelessWidget {
  final Map<dynamic, dynamic> gigData;

  final dynamic docId;

  final dynamic id;

  const GigCard(
      {super.key,
      required this.gigData,
      required this.docId,
      required this.id});

  @override
  Widget build(BuildContext context) {
    Color iconColor() {
      if (gigData["status"]) {
        return Colors.green;
      } else {
        return Colors.red;
      }
    }

    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      EditGigPage(gigData: gigData, docId: id)));
        },
        child: Container(
            decoration: const BoxDecoration(
              color: Color.fromARGB(16, 255, 255, 255),
              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.campaign,
                  color: iconColor(),
                  size: 30,
                ),
                Text(
                  gigData['skillName'],
                  style: const TextStyle(
                    fontSize: 30,
                    color: Color.fromRGBO(236, 187, 32, 1),
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  color: Color.fromRGBO(236, 187, 32, 1),
                  size: 30,
                ),
              ],
            )));
  }
}

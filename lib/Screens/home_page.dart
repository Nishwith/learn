import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/Screens/user_gig.dart';
import 'package:learn/utilities.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "LEarn"),
      drawer: const CustomDrawer(),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('gigs').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Error fetching gigs'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: CircularProgressIndicator(
                  color: Color.fromRGBO(236, 187, 32, 1),
                ));
              }

              // Fetch the gig data
              final gigDocs = snapshot.data?.docs;

              if (gigDocs == null || gigDocs.isEmpty) {
                return const Center(child: Text('No gigs available'));
              }

              // Display the gigs in a ListView
              return ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: gigDocs.length,
                itemBuilder: (context, index) {
                  // Get each gig document data
                  var gigData = gigDocs[index].data() as Map<String, dynamic>;
                  var docId = gigDocs[index].id;
                  return GigCard(gigData: gigData, docId: docId);
                },
              );
            },
          ),
          const BottomNavBar(),
        ],
      ),
    );
  }
}

class GigCard extends StatelessWidget {
  final Map<dynamic, dynamic> gigData;

  final dynamic docId;

  const GigCard({super.key, required this.gigData, required this.docId});

  @override
  Widget build(BuildContext context) {
    final String? money = gigData["money"]?.toString();
    final String? exchangeSkill = gigData["exchange skill"];
    bool num = false;
    if (money != null && money != "null" && money != "0") {
      num = true;
    }
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    UserGigPage(gigData: gigData, docId: docId)));
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Color.fromARGB(16, 255, 255, 255),
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      capitalizeFirstLetter(gigData["name"] ??
                          "Unknown Name"), // Fallback if name is null
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontFamily: "poppins",
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      capitalizeFirstLetter(gigData["skill"] ??
                          "No Skill"), // Fallback if skill is null
                      style: const TextStyle(
                        color: Color.fromRGBO(236, 187, 32, 1),
                        fontWeight: FontWeight.w400,
                        fontFamily: "poppins",
                        fontSize: 18,
                      ),
                    )
                  ],
                ),
                ClipOval(
                  child: Image(
                    image: NetworkImage(
                      gigData["img"] ??
                          "https://via.placeholder.com/50", // Placeholder if image URL is null
                    ),
                    height: 50,
                    width: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.broken_image,
                        color: Colors.red,
                        size: 50,
                      ); // Fallback if image fails to load
                    },
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Text(
              limitText(gigData["description"] ?? "", 15),
              style: const TextStyle(
                color: Color.fromRGBO(255, 255, 255, 1),
                fontWeight: FontWeight.w400,
                fontFamily: "poppins",
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
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
                          '₹$money',
                          style: const TextStyle(
                            color: Color.fromRGBO(236, 187, 32, 1),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/Screens/chat_page.dart';
import 'package:learn/utilities.dart';

class CommunicationPage extends StatefulWidget {
  const CommunicationPage({super.key});

  @override
  State<CommunicationPage> createState() => _CommunicationPageState();
}

class _CommunicationPageState extends State<CommunicationPage> {
  @override
  Widget build(BuildContext context) {
    final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: const CustomAppBar(title: "Communication"),
      drawer: CustomDrawer(),
      body: Stack(children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('chats')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                  child: Text(
                "No active chats",
                style: TextStyle(fontSize: 26, color: Colors.white),
              ));
            }

            final chatDocs = snapshot.data!.docs.reversed.toList();

            return ListView.builder(
              itemCount: chatDocs.length,
              itemBuilder: (context, index) {
                var chatData = chatDocs[index].data() as Map<String, dynamic>;
                String name = chatData['tutorName'];
                if (chatData['TutorId'] == currentUserId) {
                  name = chatData['requesterName'];
                }
                return Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                        color: const Color.fromRGBO(236, 187, 32, 1)),
                    color: const Color.fromARGB(16, 255, 255, 255),
                  ),
                  child: ListTile(
                    title: Text(
                      capitalizeFirstLetter(name),
                      style: const TextStyle(color: Colors.white),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            chatId: chatDocs[index].id,
                            name: name,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
        BottomNavBar(
          pageIndex: 3,
        ),
      ]),
    );
  }
}

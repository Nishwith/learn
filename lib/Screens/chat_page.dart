// import 'package:agora_uikit/agora_uikit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:learn/utilities.dart';

class ChatPage extends StatefulWidget {
  final String chatId;
  final String name;

  const ChatPage({super.key, required this.chatId, required this.name});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  DocumentSnapshot? chatData;
  final TextEditingController _messageController = TextEditingController();
  bool courseStatus = false;
  String? currentUserUid;

  @override
  void initState() {
    super.initState();
    getChatData();
    getCurrentUserUid();
  }

  void startVideoCall() async {
    String roomId = widget.chatId;
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': currentUserUid,
      'msgType': 'videocall',
      'roomId': roomId,
      'timestamp': FieldValue.serverTimestamp(),
    });
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => CallPage(
    //         name: widget.name,
    //         userId: currentUserUid as String,
    //         callID: widget.chatId),
    //   ),
    // );
  }

  Future<void> getCurrentUserUid() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserUid = user.uid;
      });
    }
  }

  Future<void> getChatData() async {
    var snapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .get();

    if (snapshot.exists) {
      setState(() {
        chatData = snapshot;
        courseStatus =
            (snapshot.data() as Map<String, dynamic>)['status'] != "pending";
      });
    }
  }

  void sendMessage() async {
    if (_messageController.text.trim().isEmpty || chatData == null) return;

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .add({
      'senderId': currentUserUid,
      'content': _messageController.text.trim(),
      'msgType': 'message',
      'timestamp': FieldValue.serverTimestamp(),
    });

    _messageController.clear();
  }

  void acceptCourse() {
    showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 21, 21, 21),
            title: const Text('Do you Agree for the Course.',
                style: TextStyle(
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
                  setState(() {
                    courseStatus = true;
                  });
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .update({'status': 'accepted', "appCharges": false});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chatId: widget.chatId,
                        name: widget.name,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Accept!',
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

  void payForCourse() {
    showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: const Color.fromARGB(255, 21, 21, 21),
            title: const Text('Do you Agree for the Course.',
                style: TextStyle(
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
                  FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.chatId)
                      .update({"appCharges": true});
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        chatId: widget.chatId,
                        name: widget.name,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Pay!',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: widget.name),
      drawer: CustomDrawer(),
      body: Column(
        children: [
          if (chatData != null) ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Requesting Skill: ${chatData!['requestedSkill']}",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  if ((chatData!.data() as Map<String, dynamic>)
                      .containsKey('courseAmount'))
                    Column(
                      children: [
                        const Text(
                          "Exchange Type: Money",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          "Course Amount: ${(chatData!.data() as Map<String, dynamic>)['courseAmount']}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  if ((chatData!.data() as Map<String, dynamic>)
                      .containsKey('exchangeSkill'))
                    Column(
                      children: [
                        const Text(
                          "Exchange Type: Skill",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          "Exchange Skill: ${(chatData!.data() as Map<String, dynamic>)['exchangeSkill']}",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 18),
                        ),
                      ],
                    ),
                  if (!courseStatus)
                    currentUserUid !=
                            (chatData!.data()
                                as Map<String, dynamic>)['requesterId']
                        ? InkWell(
                            onTap: () {
                              acceptCourse();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: const Color.fromRGBO(236, 187, 32, 1),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              child: const Text(
                                "Accept Course",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                          )
                        : const Text(
                            "Waiting for Tutor's Response",
                            style: TextStyle(
                                color: Color.fromRGBO(236, 187, 32, 1),
                                fontSize: 16),
                          ),
                  if (courseStatus)
                    (chatData!.data() as Map<String, dynamic>)['appCharges']
                        ? Container(
                            padding: const EdgeInsets.all(10),
                            margin: const EdgeInsets.only(top: 8),
                            decoration: const BoxDecoration(
                                color: Color.fromRGBO(236, 187, 32, 1),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: InkWell(
                              onTap: startVideoCall,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam,
                                    size: 30,
                                  ),
                                  Text("Start the Class")
                                ],
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () {
                              payForCourse();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                color: const Color.fromRGBO(236, 187, 32, 1),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              child: const Text(
                                "Pay For Course!",
                                style: TextStyle(
                                  color: Color.fromARGB(255, 0, 0, 0),
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                          ),
                ],
              ),
            ),
          ] else
            const Center(child: CircularProgressIndicator()),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                var messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isCurrentUser = message['senderId'] == currentUserUid;
                    bool isVideoCall = message['msgType'] == 'videocall';

                    return Align(
                      alignment: isCurrentUser
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: isVideoCall
                          ? InkWell(
                              onTap: () {
                                // Navigator.push(
                                //   context,
                                //   MaterialPageRoute(
                                //     builder: (context) => CallPage(
                                //         name: widget.name,
                                //         userId: currentUserUid as String,
                                //         callID: widget.chatId),
                                //   ),
                                // );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: isCurrentUser
                                      ? const Color.fromRGBO(236, 187, 32, 1)
                                      : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.videocam, color: Colors.black87),
                                    SizedBox(width: 8),
                                    Text(
                                      "Join Video Call",
                                      style: TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              padding: const EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? const Color.fromRGBO(236, 187, 32, 1)
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text(
                                message['content'] ?? '',
                                style: TextStyle(
                                  color: isCurrentUser
                                      ? const Color.fromARGB(255, 0, 0, 0)
                                      : Colors.black87,
                                ),
                              ),
                            ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            color: const Color.fromARGB(255, 0, 0, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(
                      fontFamily: "Poppins",
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 18,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Type a message",
                      focusedBorder: InputBorder.none,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Color.fromRGBO(236, 187, 32, 1),
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                      ),
                    ),
                    onSubmitted: (value) => sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: const Icon(Icons.send,
                      color: Color.fromRGBO(236, 187, 32, 1)),
                  onPressed: sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// class CallPage extends StatefulWidget {
//   final String callID;
//   final String name;
//   final String userId;
//   const CallPage({
//     super.key,
//     required this.callID,
//     required this.name,
//     required this.userId,
//   });

//   @override
//   State<CallPage> createState() => _CallPageState();
// }

// class _CallPageState extends State<CallPage> {
//   AgoraClient? client;
//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//   }

//   void initAgora() async {
//     client = AgoraClient(
//         agoraConnectionData: AgoraConnectionData(
//             appId: "be13acc813594c1f9c800313984ee726",
//             channelName: widget.callID,
//             username: widget.name));
//     await client!.initialize();
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//         child: Stack(
//       children: [
//         AgoraVideoViewer(
//           client: client!,
//           layoutType: Layout.oneToOne,
//           enableHostControls: true,
//         ),
//         AgoraVideoButtons(
//           client: client!,
//         )
//       ],
//     ));
//   }
// }
// ZegoUIKitPrebuiltCall(
//           appID: 1556018654,
//           appSign:
//               'fdb6e4c948b60a7d3719afce06351047649c47047560fafef7561a0775739273',
//           userID: widget.userId,
//           userName: "user_${widget.name}",
//           callID: widget.callID,
//           config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()),
//     );
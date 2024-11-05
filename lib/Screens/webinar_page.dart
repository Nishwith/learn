import 'package:flutter/material.dart';
import 'package:learn/utilities.dart';

class WebinarPage extends StatefulWidget {
  const WebinarPage({super.key});

  @override
  State<WebinarPage> createState() => _WebinarPageState();
}

class _WebinarPageState extends State<WebinarPage> {
  final List<Map<String, dynamic>> webinarDataList = [
    {
      "name": "Nishwith Ache",
      "topic": "Flutter",
      "imageUrl": "assets/images/avatar2.jpg",
      "description":
          "Learn the basics of Flutter and build cross-platform apps.",
      "seatsRemaining": 10,
    },
    {
      "name": "Pranav",
      "topic": "Editing",
      "imageUrl": "assets/images/avatar1.jpg",
      "description": "Master video editing techniques with this webinar.",
      "seatsRemaining": 15,
    },
    {
      "name": "Jaswanth",
      "topic": "Nutrition",
      "imageUrl": "assets/images/avatar2.jpg",
      "description": "Understand the essentials of a balanced diet.",
      "seatsRemaining": 12,
    },
    {
      "name": "Jagadeesh",
      "topic": "Artificial Intelligence",
      "imageUrl": "assets/images/avatar1.jpg",
      "description": "Explore the fundamentals of Artificial Intelligence.",
      "seatsRemaining": 8,
    },
    {
      "name": "Lucky",
      "topic": "Social Media",
      "imageUrl": "assets/images/avatar2.jpg",
      "description": "Tips and tricks to excel at creating online content.",
      "seatsRemaining": 20,
    },
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(title: "LEarn"),
        drawer: CustomDrawer(),
        body: Stack(children: [
          ListView.builder(
              padding: const EdgeInsets.only(bottom: 100),
              itemCount: webinarDataList.length,
              itemBuilder: (context, index) {
                return WebinarCard(webinarData: webinarDataList[index]);
              }),
          BottomNavBar(
            pageIndex: 2,
          ),
        ]));
  }
}

class WebinarCard extends StatefulWidget {
  final Map<String, dynamic> webinarData;

  const WebinarCard({super.key, required this.webinarData});

  @override
  State<WebinarCard> createState() => _WebinarCardState();
}

class _WebinarCardState extends State<WebinarCard> {
  late int seatsRemaining;
  bool isJoined = false;
  @override
  void initState() {
    super.initState();
    seatsRemaining = widget.webinarData["seatsRemaining"] ?? 0;
  }

  void toggleJoin() {
    setState(() {
      if (isJoined) {
        seatsRemaining += 1;
      } else {
        if (seatsRemaining > 0) {
          seatsRemaining -= 1;
        }
      }
      isJoined = !isJoined;
    });
  }

  // Helper function to capitalize the first letter
  String capitalizeFirstLetter(String text) {
    return text.isNotEmpty
        ? '${text[0].toUpperCase()}${text.substring(1)}'
        : text;
  }

  @override
  Widget build(BuildContext context) {
    final String? webinarName = widget.webinarData["name"];
    final String? topic = widget.webinarData["topic"];
    final String? description = widget.webinarData["description"];
    final String? imageUrl =
        widget.webinarData["imageUrl"] ?? "https://via.placeholder.com/150";

    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(16, 255, 255, 255),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.all(15),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    capitalizeFirstLetter(webinarName ?? "Unknown Webinar"),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontFamily: "Poppins",
                      fontSize: 22,
                    ),
                  ),
                  Text(
                    capitalizeFirstLetter(topic ?? "No Topic"),
                    style: const TextStyle(
                      color: Color.fromRGBO(236, 187, 32, 1),
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              ClipOval(
                child: Image(
                  image: AssetImage(imageUrl!),
                  height: 50,
                  width: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.broken_image,
                      color: Colors.red,
                      size: 50,
                    );
                  },
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description ?? "",
            style: const TextStyle(
              color: Color.fromRGBO(255, 255, 255, 1),
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Seats Remaining: $seatsRemaining',
                style: const TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                ),
              ),
              ElevatedButton(
                onPressed: toggleJoin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isJoined
                      ? const Color.fromARGB(255, 255, 255, 255)
                      : const Color.fromRGBO(236, 187, 32, 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  isJoined ? "Not Interested" : "Join",
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

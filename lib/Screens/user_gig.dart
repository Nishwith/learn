import 'package:flutter/material.dart';
import 'package:learn/utilities.dart';

class UserGigPage extends StatefulWidget {
  final dynamic gigData;
  final dynamic docId;

  const UserGigPage({super.key, required this.gigData, required this.docId});

  @override
  State<UserGigPage> createState() => _UserGigPageState();
}

class _UserGigPageState extends State<UserGigPage> {
  @override
  Widget build(BuildContext context) {
    final String? money = widget.gigData["money"]?.toString();
    final String? exchangeSkill = widget.gigData["exchange skill"];
    bool num = false;
    if (money != null && money != "null" && money != "0") {
      num = true;
    }
    // Split the course outline into a list based on double spaces
    String courseOutlineString =
        widget.gigData["course outline"] ?? "No outline";
    List<String> courseOutline = courseOutlineString
        .split("  ") // Split by double spaces
        .map((item) => item.trim()) // Trim whitespace from each item
        .where((item) => item.isNotEmpty) // Filter out any empty strings
        .cast<String>() // Cast to List<String>
        .toList();

    return Scaffold(
      appBar: const CustomAppBar(title: "LEarn"),
      drawer: const CustomDrawer(),
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
                    image: NetworkImage(widget.gigData["img"]),
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
                  capitalizeFirstLetter(widget.gigData["skill"] ?? "No Skill"),
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
                InkWell(
                  onTap: () {
                    launchURL(widget.gigData["portfolio"]);
                  },
                  child: Text(
                    widget.gigData["portfolio"] ?? "No Description",
                    style: const TextStyle(
                      color: Color.fromRGBO(12, 0, 177, 1),
                      fontWeight: FontWeight.w400,
                      fontFamily: "poppins",
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                const Divider(),
                const SizedBox(height: 5),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Course Certificate: ${capitalizeFirstLetter(widget.gigData["course certificate"] ?? "No Description")}",
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
                )
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
                'Are you Really want to send the Request to ${capitalizeFirstLetter(widget.gigData["name"])} for ${capitalizeFirstLetter(widget.gigData["skill"])}',
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
                  'cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                    color: Color.fromRGBO(255, 255, 255, 1),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final String? money = widget.gigData["money"]?.toString();
                  final String? exchangeSkill =
                      widget.gigData["exchange skill"];
                  bool num = false;
                  if (money != null && money != "null" && money != "0") {
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
                              'In what Exchage do you want to learn  ${capitalizeFirstLetter(widget.gigData["skill"])} from ${capitalizeFirstLetter(widget.gigData["name"])}',
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
                                        '₹$money',
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
                              onPressed: () {},
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
                                  : Container(), // Fallback empty container if condition is false
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

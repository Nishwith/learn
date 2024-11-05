// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn/Screens/account_page.dart';
import 'package:learn/Screens/communication_page.dart';
import 'package:learn/Screens/gig_page.dart';
import 'package:learn/Screens/home_page.dart';
import 'package:learn/Screens/splash_screen.dart';
import 'package:learn/Screens/webinar_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class TextFieldWidget extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final bool isPassword;
  final bool maxLine;
  final bool typeNumber;

  const TextFieldWidget({
    super.key,
    required this.text,
    required this.controller,
    required this.isPassword,
    required this.typeNumber,
    required this.maxLine,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _isObscured = true;
  bool typeNumber = false;
  bool maxLine = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
    typeNumber = widget.typeNumber;
    maxLine = widget.maxLine;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        keyboardType: typeNumber ? TextInputType.number : null,
        inputFormatters: typeNumber
            ? <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly]
            : null,
        controller: widget.controller,
        maxLines: maxLine ? 3 : 1,
        obscureText: widget.isPassword && _isObscured,
        cursorColor: const Color.fromRGBO(236, 187, 32, 1),
        decoration: InputDecoration(
          hintText: widget.text,
          labelText: widget.text,
          hintStyle: const TextStyle(
            fontFamily: "Poppins",
          ),
          labelStyle: const TextStyle(
            fontFamily: "Poppins",
            color: Color.fromRGBO(255, 255, 255, 1),
          ),
          border: const OutlineInputBorder(
            borderSide: BorderSide(
              color: Color.fromRGBO(236, 187, 32, 1),
            ),
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          fillColor: const Color.fromARGB(21, 217, 217, 217),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(50)),
            borderSide: BorderSide(
              color: Color.fromRGBO(236, 187, 32, 1),
            ),
          ),
          filled: true,
          suffixIcon: widget.isPassword
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility : Icons.visibility_off,
                    color: const Color.fromRGBO(236, 187, 32, 1),
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
        style: const TextStyle(
          fontFamily: "Poppins",
          color: Color.fromRGBO(255, 255, 255, 1),
          fontSize: 20,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the field.';
          }
          return null;
        },
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          Scaffold.of(context).openDrawer(); // This will open the Drawer
        },
        icon: const Icon(Icons.menu,
            size: 28, color: Color.fromRGBO(236, 187, 32, 1)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color.fromRGBO(236, 187, 32, 1),
          fontFamily: 'Poppins',
          fontSize: 30,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Add your search logic here
          },
          icon: const Icon(
            Icons.search,
            size: 30,
            color: Color.fromRGBO(236, 187, 32, 1),
          ),
        )
      ],
      backgroundColor: Colors.black, // Customize background color if needed
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({super.key});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final int randomNumber = Random().nextInt(2) + 1;
  String? userName;
  String? userImg;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      final userDoc =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      setState(() {
        userName = userDoc['Full Name'];
        userImg = userDoc['userImg'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const AccountPage()));
            },
            child: DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(236, 187, 32, 1),
              ),
              child: Center(
                child: Column(
                  children: [
                    ClipOval(
                      child: userImg != null
                          ? Image.network(
                              userImg!,
                              height: 75,
                              width: 75,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              "assets/images/avatar$randomNumber.jpg",
                              height: 75,
                              width: 75,
                            ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userName != null ? "Hello, $userName!" : "Hello!",
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.home,
            label: 'Home',
            page: const HomePage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.campaign,
            label: 'Campaign gigs',
            page: const GigPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.groups,
            label: 'Webinar',
            page: const WebinarPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.chat,
            label: 'Chat',
            page: const CommunicationPage(),
          ),
          _buildDrawerItem(
            context,
            icon: Icons.person_sharp,
            label: 'Account',
            page: const AccountPage(),
          ),
          ListTile(
            iconColor: const Color.fromRGBO(236, 187, 32, 1),
            textColor: const Color.fromRGBO(236, 187, 32, 1),
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.remove('uid');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SplashScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context,
      {required IconData icon, required String label, required Widget page}) {
    return ListTile(
      iconColor: const Color.fromRGBO(236, 187, 32, 1),
      textColor: const Color.fromRGBO(236, 187, 32, 1),
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
    );
  }
}

class BottomNavBar extends StatefulWidget {
  int pageIndex;
  BottomNavBar({super.key, required this.pageIndex});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    final List<IconData> navIcons = [
      Icons.home,
      Icons.campaign,
      Icons.groups,
      Icons.chat,
      Icons.person_sharp
    ];

    final List<Widget> screens = [
      const HomePage(),
      const GigPage(),
      const WebinarPage(),
      const CommunicationPage(),
      const AccountPage(),
    ];

    int selectedIndex = widget.pageIndex;

    void onTap(int index) {
      setState(() {
        selectedIndex = index;
      });
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => screens[index]));
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: 70,
        margin: const EdgeInsets.only(right: 16, left: 16, bottom: 16),
        decoration: BoxDecoration(
            color: const Color.fromRGBO(236, 187, 32, 1),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: const Color.fromRGBO(236, 187, 32, 1).withAlpha(69),
                  blurRadius: 5,
                  spreadRadius: 2)
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: navIcons.map((icon) {
            int index = navIcons.indexOf(icon);
            bool isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => onTap(index),
              child: Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 15),
                child: Icon(
                  icon,
                  size: isSelected ? 38 : 32,
                  color:
                      isSelected ? Colors.black : Colors.black.withAlpha(180),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

String limitText(String text, int wordLimit) {
  List<String> words = text.split(' ');
  if (words.length > wordLimit) {
    return '${words.take(wordLimit).join(' ')}...';
  } else {
    return text;
  }
}

Future<void> launchURL(Uri url) async {
  // Check if the URL can be launched
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

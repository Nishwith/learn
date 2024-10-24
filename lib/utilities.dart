// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn/Screens/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

class TextFieldWidget extends StatefulWidget {
  final String text;
  final TextEditingController controller;
  final bool isPassword;
  final bool typeNumber;

  const TextFieldWidget({
    super.key,
    required this.text,
    required this.controller,
    required this.isPassword,
    required this.typeNumber,
  });

  @override
  // ignore: library_private_types_in_public_api
  _TextFieldWidgetState createState() => _TextFieldWidgetState();
}

class _TextFieldWidgetState extends State<TextFieldWidget> {
  bool _isObscured = true;
  bool typeNumber = false;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.isPassword;
    typeNumber = widget.typeNumber;
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
            size: 30, color: Color.fromRGBO(236, 187, 32, 1)),
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

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black,
      child: ListView(
        children: const [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromRGBO(236, 187, 32, 1),
            ),
            child: Text('Header'),
          ),
          ListTile(
            title: Text('Item 1'),
            leading: Icon(Icons.dashboard),
          ),
          ListTile(
            title: Text('Item 2'),
            leading: Icon(Icons.settings),
          ),
        ],
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
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
    const Webinar(),
    const Communication(),
    const Account(),
  ];

  int selectedIndex = 0;

  void onTap(int index) {
    setState(() {
      selectedIndex = index;
    });
    // print()  ;
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => screens[index]));
  }

  @override
  Widget build(BuildContext context) {
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

// Dummy Screens for testing

class GigPage extends StatelessWidget {
  const GigPage({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      'Gig Page',
      style: TextStyle(color: Colors.white),
    ));
  }
}

class Webinar extends StatelessWidget {
  const Webinar({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      'Webinar Page',
      style: TextStyle(color: Colors.white),
    ));
  }
}

class Communication extends StatelessWidget {
  const Communication({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      'Communication Page',
      style: TextStyle(color: Colors.white),
    ));
  }
}

class Account extends StatelessWidget {
  const Account({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(
        child: Text(
      'Account Page',
      style: TextStyle(color: Colors.white),
    ));
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

Future<void> launchURL(String url) async {
  // Check if the URL can be launched
  if (await canLaunchUrl(url as Uri)) {
    await launchUrl(url as Uri);
  } else {
    throw 'Could not launch $url';
  }
}

String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

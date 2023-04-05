import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:transcribe_mate/ui/GalleryScreen.dart';
import 'package:transcribe_mate/ui/LiveTranscribeScreen.dart';
import 'package:transcribe_mate/ui/NotesScreen.dart';
import 'UserInfoScreen.dart';
import '../constants/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  List<Widget> pages = <Widget>[];
  static const String prefSelectedIndexKey = 'selectedIndex';

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;

    pages.add(const GalleryScreen());
    pages.add(NoteListScreen());
    pages.add(const LiveTranscribeScreen());
    if (user != null) {
      pages.add(UserInfoScreen(user: user));
    }
    getCurrentIndex();
  }

  void saveCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt(prefSelectedIndexKey, _selectedIndex);
  }

  void getCurrentIndex() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(prefSelectedIndexKey)) {
      setState(() {
        final index = prefs.getInt(prefSelectedIndexKey);
        if (index != null) {
          _selectedIndex = index;
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    saveCurrentIndex();
  }

  @override
  Widget build(BuildContext context) {
    String title;
    switch (_selectedIndex) {
      case 0:
        title = "Gallery";
        break;
      case 1:
        title = "Notes";
        break;
      case 2:
        title = "Live Transcribe";
        break;
      default:
        title = "Account";
        break;
    }
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(40.0),
        child: AppBar(
          title: const Text(
            "TranscribeMate",
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'ProductSans',
            ),
          ),
        ),
      ),
      body: Container(
        child: pages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.photo_album,
              color: _selectedIndex == 0 ? darkOrange : Colors.black,
              semanticLabel: "Gallery",
            ),
            label: "Gallery",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.notes,
              color: _selectedIndex == 1 ? darkOrange : Colors.black,
              semanticLabel: "Notes",
            ),
            label: "Notes",
          ),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.transcribe,
                color: _selectedIndex == 2 ? darkOrange : Colors.black,
                semanticLabel: "Live Transcribe",
              ),
              label: "Live Transcribe"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.account_box_rounded,
                color: _selectedIndex == 3 ? darkOrange : Colors.black,
                semanticLabel: "Account",
              ),
              label: "Account"),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: darkOrange,
        onTap: _onItemTapped,
        unselectedItemColor: Colors.black,
        showSelectedLabels: true,
        showUnselectedLabels: false,
        enableFeedback: false,
      ),
    );
  }
}

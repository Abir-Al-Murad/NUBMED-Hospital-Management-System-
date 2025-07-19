import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/pages/HomePage.dart';
import 'package:nubmed/pages/Profile.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/_fetchImage.dart';

class WidgetTree extends StatefulWidget {
  WidgetTree({super.key});

  static String name = '/widget-tree';

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree> {

  List screens = [
    Homepage(),
    Homepage(),
    Homepage(),
  ];
  String? photoUrl;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    FetchImage.fetchImageUrl(uid).then((url) {
      if (url != null) {
        setState(() {
          photoUrl = url;
        });
      }
    });
  }


  int i = 0;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("NUBMED",style: TextStyle(letterSpacing: 1.7),),
        actions: [
          Padding(
            padding: const EdgeInsets.all(6.0),
            child: GestureDetector(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile()));
              },
              child: Container(
                padding: EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,
                      Colors.greenAccent,
                      Colors.cyan,
                    ],
                  ),
                ),
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: photoUrl != null
                        ? NetworkImage(photoUrl!)
                        : AssetImage("assets/blank person.jpg") as ImageProvider,

                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: screens[i],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Color_codes.meddle,
        currentIndex: i,
        onTap: (index) {
          setState(() {
            i = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
        ],
      ),
    );
  }

}

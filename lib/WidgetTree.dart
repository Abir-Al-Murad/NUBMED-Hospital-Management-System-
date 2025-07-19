import 'package:flutter/material.dart';
import 'package:nubmed/pages/HomePage.dart';
import 'package:nubmed/pages/Profile.dart';
import 'package:nubmed/utils/Color_codes.dart';

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

  int i = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: Image.asset("assets/NUBMED logo.png",height: 100,fit: BoxFit.contain,),
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
                    backgroundImage: NetworkImage(
                      "https://imgs.search.brave.com/HKfaFyIPjOR3sF0namUadB5xtbJR-ssRhPgaOq5RTOg/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9jZG4u/cGl4YWJheS5jb20v/cGhvdG8vMjAxNC8w/OS8xNy8xMS80Ny9t/YW4tNDQ5NDA0XzY0/MC5qcGc",
                    ),
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

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/pages/Admin_Pages/AdminHealthTipsPage.dart';
import 'package:nubmed/pages/Admin_Pages/AdminMedicine.dart';
import 'package:nubmed/pages/AppoinmentPage.dart';
import 'package:nubmed/pages/Blood_page.dart';
import 'package:nubmed/pages/Doctor_Page.dart';
import 'package:nubmed/pages/LabTestPage.dart';
import 'package:nubmed/pages/health_tips.dart';
import 'package:nubmed/pages/medicine_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  static String name = '/home-page';

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;


  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CarouselSlider(items: [
                Card(
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/wear_mask.jpg",fit: BoxFit.cover,width: double.maxFinite,)),
                ),
                Card(
                  child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(10),
                      child: Image.asset("assets/mask.jpg",fit: BoxFit.cover,width: double.maxFinite,)),
                ),
              ], options: CarouselOptions(
                height: 200,
                autoPlay: true,
                enlargeCenterPage: true,
                viewportFraction: 1,
              )),
              const SizedBox(height: 20),
              Text(
                "Services",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 19,color: Colors.black),
              ),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: [
                  buildGridItem(
                    icon: Icons.person,
                    label: "Doctor",
                    color: Colors.pinkAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DoctorPage()),
                      );
                    },
                  ),
                  buildGridItem(
                    icon: Icons.science,
                    label: "Lab Test",
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const LabtestPage()),
                      );
                    },
                  ),
                  buildGridItem(
                    icon: Icons.calendar_today,
                    label: "Appointment",
                    color: Colors.teal,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  Appointmentpage()),
                      );
                    },
                  ),
                  buildGridItem(
                    icon: Icons.emergency,
                    label: "Emergency",
                    color: Colors.redAccent,
                    onTap: () {
                      // TODO: Emergency page navigation
                    },
                  ),
                  buildGridItem(
                    icon: Icons.medication,
                    label: "Medicine",
                    color: Colors.brown,
                    onTap: () {
                      (CheckAdmin.isAdminUser)?Navigator.pushNamed(context, AdminMedicinePage.name): Navigator.pushNamed(context, MedicinePage.name);
                    },
                  ),
                  buildGridItem(
                    icon: Icons.bloodtype,
                    label: "Blood Support",
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  BloodPage()),
                      );
                    },
                  ),
                  buildGridItem(
                    icon: Icons.health_and_safety,
                    label: "Health Tips",
                    color: Colors.green,
                    onTap: () {
                      print(CheckAdmin.isAdminUser);
                      CheckAdmin.isAdminUser == true?Navigator.pushNamed(context, AdminHealthTipsPage.name) : Navigator.pushNamed(context, HealthTips.name);
                    },
                  ),
                  buildGridItem(
                    icon: Icons.history_edu,
                    label: "History",
                    color: Colors.blueGrey,
                    onTap: () {
                      // TODO: History page navigation
                    },
                  ),
                  buildGridItem(icon: Icons.support_agent_rounded, label: "Support", color: Colors.blue, onTap: (){})
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget buildGridItem({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(16),
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(8), // slightly reduced padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CircleAvatar(
                radius: 21,
                backgroundColor: color,
                child: Icon(icon, size: 24, color: Colors.white),
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


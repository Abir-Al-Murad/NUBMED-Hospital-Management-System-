import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/pages/AppoinmentPage.dart';
import 'package:nubmed/pages/Blood_page.dart';
import 'package:nubmed/pages/Doctor_Page.dart';
import 'package:nubmed/pages/LabTestPage.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> addLabTestData() async {
    CollectionReference labTests = firestore.collection('labtests');

    final labTestData = [
      {
        "testName": "Complete Blood Count (CBC)",
        "description": "Measures red cells, white cells, hemoglobin, hematocrit, and platelets in blood.",
        "sampleType": "Blood",
        "normalRange": "Varies per component",
        "price": 500,
        "preparation": "No special preparation needed",
        "department": "Pathology",
        "turnaroundTime": "24 hours"
      },
      {
        "testName": "Fasting Blood Sugar",
        "description": "Measures blood glucose after fasting for 8-12 hours.",
        "sampleType": "Blood",
        "normalRange": "70-110 mg/dL",
        "price": 300,
        "preparation": "Fasting required for 8-12 hours",
        "department": "Biochemistry",
        "turnaroundTime": "4 hours"
      },
      // ... more test data
    ];

    for (var test in labTestData) {
      await labTests.add(test);
    }
  }

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
            children: [
              CarouselSlider(items: [
                Card(
                  elevation: 5,
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset("assets/wear_mask.jpg",fit: BoxFit.cover,width: double.maxFinite,)),
                ),
                Card(
                  elevation: 5,
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
              const Text(
                "Services",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                      // TODO: Medicine page navigation
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
                      // TODO: Health Tips page navigation
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
                  buildGridItem(icon: Icons.support_agent_rounded, label: "Support", color: Colors.black, onTap: (){})
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
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: color.withOpacity(0.1),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                overflow: TextOverflow.ellipsis
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

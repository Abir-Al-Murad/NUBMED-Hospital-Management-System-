

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/pages/Admin_Pages/AdminHealthTipsPage.dart';
import 'package:nubmed/pages/Admin_Pages/AdminMedicine.dart';
import 'package:nubmed/pages/Admin_Pages/available_doctor_list.dart';
import 'package:nubmed/pages/AppoinmentPage.dart';
import 'package:nubmed/pages/Blood_HomePage.dart';
import 'package:nubmed/pages/Doctor_Page.dart';
import 'package:nubmed/pages/LabTestPage.dart';
import 'package:nubmed/pages/emergency.dart';
import 'package:nubmed/pages/health_tips.dart';
import 'package:nubmed/pages/medicine_page.dart';
import 'package:nubmed/pages/support_page.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/pickImage_imgbb.dart';

import 'history_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  static String name = '/home-page';

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> _sliderDocs = [];
  bool _isLoading = true;
  Future<void> _fetchSliderImages() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('slider')
          .get();
      setState(() {
        _sliderDocs = snapshot.docs; // Store the full document snapshots
      });
    } catch (e) {
      debugPrint('Error fetching slider images: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchSliderImages();
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
              CarouselSlider(
                items: _sliderDocs.map((doc) {
                  final imageData = doc.data() as Map<String, dynamic>;
                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: CachedNetworkImage(imageUrl: imageData['image']),
                        ),
                        if (Administrator.isAdminUser ||
                            Administrator.isModeratorUser)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(2, 2),
                                  ),
                                ],
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.delete_forever_rounded,
                                  color: Colors.red[600],
                                  size: 25,
                                ),
                                tooltip: 'Delete Image',
                                onPressed: () async {
                                  final imageData = doc.data() as Map<String, dynamic>;
                                  final deleteUrl = imageData['delete_image'];
                                  print(deleteUrl);

                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12)),
                                      title: const Text("Confirm Delete"),
                                      content: const Text("Are you sure you want to delete this image?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, false),
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.pop(context, true),
                                          child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                      false;

                                  if (confirmDelete) {
                                    await FirebaseFirestore.instance.collection('slider').doc(doc.id).delete();
                                    await _fetchSliderImages(); // Refresh
                                  }
                                },
                              ),
                            ),
                          ),

                      ],
                    ),
                  );
                }).toList(),
                options: CarouselOptions(
                  aspectRatio: 16 / 9,
                  viewportFraction: 0.9,
                  autoPlay: true,
                  enlargeCenterPage: true,
                  autoPlayCurve: Curves.easeInCubic,
                  enlargeFactor: 0.5
                ),
              ),
              if (Administrator.isAdminUser || Administrator.isModeratorUser)
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      final pickedImage = await ImgBBImagePicker.pickImage();
                      if (pickedImage == null) {
                        showsnakBar(context, 'No image selected', false);
                        return;
                      }

                      showsnakBar(context, 'Uploading image...', true);
                      final response = await ImgBBImagePicker.uploadImage(
                          imageFile: pickedImage,
                          context: context
                      );

                      if (response != null) {
                        await FirebaseFirestore.instance.collection('slider').add({
                          'image': response.imageUrl,
                          'delete_image': response.deleteUrl,
                        });
                        await _fetchSliderImages(); // Refresh the list
                        showsnakBar(context, 'Image uploaded successfully', true);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(200, 45),
                    ),
                    child: Text(
                      "Add Image",
                      style: TextStyle(
                        color: Color_codes.deep_plus,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                "Services",
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 19,
                  color: Colors.black,
                ),
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
                      Navigator.pushNamed(context, DoctorPage.name);
                    },
                  ),
                  buildGridItem(
                    icon: Icons.science,
                    label: "Lab Test",
                    color: Colors.orange,
                    onTap: () {
                     Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LabTestPage(),
                        ),
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
                        MaterialPageRoute(
                          builder: (context) => Appointmentpage(),
                        ),
                      );
                    },
                  ),
                  buildGridItem(
                    icon: Icons.emergency,
                    label: "Emergency",
                    color: Colors.redAccent,
                    onTap: () {
                      Navigator.pushNamed(context, EmergencyScreen.name);
                    },
                  ),
                  buildGridItem(
                    icon: Icons.medication,
                    label: "Medicine",
                    color: Colors.brown,
                    onTap: () {
                      (Administrator.isAdminUser)
                          ? Navigator.pushNamed(context, AdminMedicinePage.name)
                          : Navigator.pushNamed(context, MedicinePage.name);
                    },
                  ),
                  buildGridItem(
                    icon: Icons.bloodtype,
                    label: "Blood Support",
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BloodHomepage(),
                        ),
                      );
                    },
                  ),
                  buildGridItem(
                    icon: Icons.health_and_safety,
                    label: "Health Tips",
                    color: Colors.green,
                    onTap: () {
                      print(Administrator.isAdminUser);
                      Administrator.isAdminUser == true
                          ? Navigator.pushNamed(
                              context,
                              AdminHealthTipsPage.name,
                            )
                          : Navigator.pushNamed(context, HealthTips.name);
                    },
                  ),
                  buildGridItem(
                    icon: Icons.history_edu,
                    label: "History",
                    color: Colors.blueGrey,
                    onTap: () {
                      // When you want to open the history screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HistoryPage()),
                      );
                    },
                  ),
                  buildGridItem(
                    icon: Icons.support_agent_rounded,
                    label: "Support",
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SupportScreen()),
                      );
                    },
                  ),
                  if (Administrator.isAdminUser ||
                      Administrator.isModeratorUser)
                    buildGridItem(
                      icon: Icons.app_registration_sharp,
                      label: "Patients Appointments",
                      color: Colors.blue,
                      onTap: () {
                        Navigator.pushNamed(context, AvailableDoctorList.name);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Future<void> _uploadImage(BuildContext context) async {
//   final scaffoldMessenger = ScaffoldMessenger.of(context);
//   final result = await ImagePickerHelper.pickImage();
//
//   if (result == null) {
//     scaffoldMessenger.showSnackBar(
//       const SnackBar(content: Text('No image selected')),
//     );
//     return;
//   }
//
//   try {
//     await FirebaseFirestore.instance.collection("slider").add({
//       "image_url": result.base64String,
//       "file_name": result.fileName,
//       "file_size": result.fileSize,
//       "uploaded_at": FieldValue.serverTimestamp(),
//     });
//
//     // Show success
//     scaffoldMessenger.showSnackBar(
//       const SnackBar(content: Text('Image uploaded successfully!')),
//     );
//   } catch (e, stackTrace) {
//     debugPrint('Upload error: $e\n$stackTrace');
//     scaffoldMessenger.showSnackBar(
//       SnackBar(content: Text('Upload failed: ${e.toString()}')),
//     );
//   }
// }

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
                  maxLines: 2,
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
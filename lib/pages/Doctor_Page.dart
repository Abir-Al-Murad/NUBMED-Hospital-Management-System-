import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DoctorPage extends StatelessWidget {
  const DoctorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Our Doctors"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          if (docs.isEmpty) return const Center(child: Text("No doctors available"));

          return Padding(
            padding: const EdgeInsets.all(12),
            child: GridView.builder(
              itemCount: docs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.6,
              ),
              itemBuilder: (context, index) {
                final doctor = docs[index].data() as Map<String, dynamic>;
                final List<dynamic> availableDays = doctor['availableDays'] ?? [];

                final isAvailable = isDoctorAvailableToday(availableDays);

                return Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: CachedNetworkImage(
                          imageUrl: doctor['imageUrl'] ?? 'https://imgs.search.brave.com/aUOuQymUqBq2KR8V-3PEA8L23tXV19PPJCwfCFOD8HE/rs:fit:860:0:0:0/g:ce/aHR0cHM6Ly9sb2dv/ZGl4LmNvbS9sb2dv/LzcwNjI5Mi5qcGc',
                          height: 130,
                          width: double.maxFinite,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 130,
                            color: Colors.grey[300],
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error, size: 60),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doctor['name'] ?? 'Unknown',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              doctor['specialization'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                              ),
                            ),
                            Text(
                              doctor['department'] ?? '',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green[50] : Colors.red[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isAvailable ? "Available Today" : "Not Available",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isAvailable ? Colors.green : Colors.red,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Colors.blueAccent.withOpacity(0.9),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: ()async {
                                  final querySnapshot = await FirebaseFirestore.instance.collection('appointments').where('doctorName',isEqualTo: doctor['name']).get();
                                  await FirebaseFirestore.instance.collection('appointments').add({
                                    'doctorName': doctor['name'],
                                    'userId': FirebaseAuth.instance.currentUser!.uid,
                                    'userName': FirebaseAuth.instance.currentUser!.displayName,
                                    'appointmentDate': DateTime.now(),
                                    'timestamp': FieldValue.serverTimestamp(),
                                    'serialNumber':querySnapshot.docs.length+1,
                                    'chamberTime':doctor['chamberTime'],
                                  });

                                },
                                child: const Text("Take Appointment"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  bool isDoctorAvailableToday(List<dynamic> availableDays) {
    final today = DateTime.now();
    final days = [
      'Monday', 'Tuesday', 'Wednesday',
      'Thursday', 'Friday', 'Saturday', 'Sunday'
    ][today.weekday - 1];

    return availableDays.contains(days);
  }
}

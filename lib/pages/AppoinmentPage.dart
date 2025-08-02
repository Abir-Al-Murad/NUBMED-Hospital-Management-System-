import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/utils/Color_codes.dart';

class Appointmentpage extends StatefulWidget {
  const Appointmentpage({super.key});

  @override
  State<Appointmentpage> createState() => _AppointmentpageState();
}

class _AppointmentpageState extends State<Appointmentpage> {
  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Appointments")),
        body: const Center(child: Text("Please login first.")),
      );
    }

    final Stream<QuerySnapshot> userAppointments = FirebaseFirestore.instance
        .collection('appointments')
        .where('userId', isEqualTo: currentUser.uid)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Appointments"),
        centerTitle: true,
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: userAppointments,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Firestore Error: ${snapshot.error}");
            return const Center(child: Text('Something went wrong!'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text('No appointments yet'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              print(data);
              final DateTime date = data['appointmentDate']?.toDate();
              final isOver = isAppoinmentOver(date);
              final docId = docs[index].id;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 40,
                        color: Colors.teal,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['doctorName'] ?? 'Unknown Doctor',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Date: ${date.day}/${date.month}/${date.year}',
                              style: const TextStyle(fontSize: 15),
                            ),
                            Text(
                              'Time: ${data['visiting_time']}',
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.teal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Serial: ${data['serialNumber']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: Colors.white,
                              backgroundColor: isOver
                                  ? Color_codes.deep_plus
                                  : Color_codes.meddle,
                            ),
                            onPressed: isOver
                                ? () async {
                                    await FirebaseFirestore.instance
                                        .collection('appointments')
                                        .doc(docId)
                                        .delete();
                                    setState(() {});
                                  }
                                : () {
                                    cancelAppointment(docId, data);
                                  },
                            child: Text(isOver ? "Delete" : "Cancel"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  bool isAppoinmentOver(DateTime appointmentDate) {
    try {
      // Normalize both dates to midnight (remove time components)
      final appointmentDay = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
      );

      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      if(appointmentDay.isBefore(today)){
        return true;
      }else{
        return false;
      }
    } catch (e) {
      debugPrint("Error parsing date/time: $e");
      return false;
    }
  }

  void cancelAppointment(String id, Map<String, dynamic> data) async {
    final doctorName = data['doctorName'];
    final appointmentDate = data['appointmentDate'];
    final caceledSerial = data['serialNumber'];
    await FirebaseFirestore.instance
        .collection('appointments')
        .doc(id)
        .delete();

    final querySnapshot = await FirebaseFirestore.instance
        .collection('appointments')
        .where('appointmentDate', isEqualTo: appointmentDate)
        .where('doctorName', isEqualTo: doctorName)
        .where('serialNumber', isGreaterThan: caceledSerial)
        .get();
    for (final doc in querySnapshot.docs) {
      final currentSerial = doc['serialNumber'];
      await doc.reference.update({'serialNumber': currentSerial - 1});
    }
  }
}

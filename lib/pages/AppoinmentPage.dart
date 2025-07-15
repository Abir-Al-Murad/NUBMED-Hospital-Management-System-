import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Appointmentpage extends StatelessWidget {
  const Appointmentpage({super.key});

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
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final DateTime date = data['appointmentDate']?.toDate();

              return ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(data['doctorName'] ?? 'Unknown'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: ${date.day}/${date.month}/${date.year}',),
                    Text("Doctor Chamber Time: ${data['chamberTime']}"),

                  ],
                ),
                trailing: Text('Serial : ${data['serialNumber']}'),
              );
            },
          );
        },
      ),
    );
  }
}

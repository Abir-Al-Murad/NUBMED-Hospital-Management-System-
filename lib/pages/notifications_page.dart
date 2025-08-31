import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {

  late final DocumentReference documentReference;
  Future<void> getNotification()async{
    documentReference = await FirebaseFirestore.instance.collection('notifications').doc();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No notifications yet."));
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final doc = notifications[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                elevation: 3,
                child: GestureDetector(
                  onTap: ()async{
                    await FirebaseFirestore.instance.collection('notifications').doc().get();
                  },
                  child: ListTile(
                    title: Text(data['title'] ?? "No Title"),
                    subtitle: Text(data['message'] ?? "No Message"),
                    trailing: data['read'] == true
                        ? const Icon(Icons.done_all, color: Colors.green)
                        : const Icon(Icons.notifications_active,
                        color: Colors.red),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

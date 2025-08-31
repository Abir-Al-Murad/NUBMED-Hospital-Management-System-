import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/model/user_model.dart';
import 'package:nubmed/model/users_labTest_model.dart';

class UsersLabtest extends StatefulWidget {
  const UsersLabtest({super.key});

  @override
  State<UsersLabtest> createState() => _UsersLabtestState();
}

class _UsersLabtestState extends State<UsersLabtest> {
  final Map<String, medUser> _userCache = {};

  @override
  void initState() {
    super.initState();
    _prefetchUsers();
  }

  // Prefetch all users to avoid individual lookups
  Future<void> _prefetchUsers() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();

    for (final doc in usersSnapshot.docs) {
      final user = medUser.fromFirestore(doc);
      _userCache[doc.id] = user;
    }

    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users LabTests"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('usersLabTest')
            .orderBy("timestamp", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No lab tests available"));
          }

          final labDocs = snapshot.data!.docs;

          // Show loading if users are still being prefetched
          if (_userCache.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: labDocs.length,
            itemBuilder: (context, index) {
              final doc = labDocs[index];
              final labData = UsersLabtestModel.fromFirestore(doc);
              final user = _userCache[labData.userId];

              if (user == null) {
                return ListTile(
                  title: Text(labData.testName),
                  subtitle: const Text("User not found"),
                );
              }

              return _buildLabTestCard(labData, user);
            },
          );
        },
      ),
    );
  }

  Widget _buildLabTestCard(UsersLabtestModel labData, medUser user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info and test name
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: NetworkImage(user.photoUrl),
                  onBackgroundImageError: (exception, stackTrace) =>
                  const Icon(Icons.person),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        labData.testName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        user.name,
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  labData.isDone ? Icons.check_circle : Icons.pending,
                  color: labData.isDone ? Colors.green : Colors.orange,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Test details
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Price: ${labData.testPrice}"),
                Text("Phone: ${user.phone}"),
                Text("Booked: ${_formatTimestamp(labData.timestamp)}"),
              ],
            ),

            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Done button (only show if not already done)
                if (!labData.isDone)
                  ElevatedButton.icon(
                    onPressed: () async {
                      // Update the test status to done
                      await FirebaseFirestore.instance
                          .collection('usersLabTest')
                          .doc(labData.labID)
                          .update({'isDone': true});

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Test marked as completed'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Mark as Done'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),

                const SizedBox(width: 8),

                // File submission button (only show if test is done)
                if (labData.isDone)
                  ElevatedButton.icon(
                    onPressed: () {
                      // Implement file submission logic here
                      _submitTestFile(labData);
                    },
                    icon: const Icon(Icons.upload_file, size: 18),
                    label: const Text('Submit File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

// Method to handle file submission
  void _submitTestFile(UsersLabtestModel labData) {
    // Implement your file submission logic here
    // This could open a file picker and upload to storage
    print('Submitting file for test: ${labData.testName}');

    // Example implementation:
    // 1. Show file picker
    // 2. Upload to Firebase Storage
    // 3. Update Firestore with file URL
  }

  String _formatTimestamp(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _sendTestCompletionNotification(String userId, String testName) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final fcmToken = userData['fcmToken'];

        if (fcmToken != null && fcmToken.isNotEmpty) {
          await FirebaseFirestore.instance.collection('notifications').add({
            'title': 'Lab Test Completed',
            'message': 'Your $testName test has been completed and results are ready.',
            'userId': userId,
            'timestamp': Timestamp.now(),
            'type': 'test_completion',
            'read': false,
          });
        }
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }


}
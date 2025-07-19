import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LabtestPage extends StatelessWidget {
  const LabtestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Lab Tests", style: TextStyle(fontSize: 18)),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('labtests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong!', style: TextStyle(fontSize: 16)));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final labTests = snapshot.data!.docs;

          if (labTests.isEmpty) {
            return Center(child: Text("No lab tests available.", style: TextStyle(fontSize: 16)));
          }

          return Padding(
            padding: EdgeInsets.all(10),
            child: GridView.builder(
              itemCount: labTests.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final data = labTests[index].data() as Map<String, dynamic>;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['testName'] ?? 'Unknown Test',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        Text(
                          data['department'] ?? 'No Department',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Sample: ${data['sampleType'] ?? '-'}',
                          style: TextStyle(fontSize: 11),
                        ),
                        Spacer(),
                        Text(
                          'Price: ৳${data['price'] ?? 'N/A'}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

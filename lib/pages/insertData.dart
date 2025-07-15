import 'package:cloud_firestore/cloud_firestore.dart';

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

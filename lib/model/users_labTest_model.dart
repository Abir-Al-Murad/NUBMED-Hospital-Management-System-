import 'package:cloud_firestore/cloud_firestore.dart';

class UsersLabtestModel {
  final String labID;
  final String testName;
  final double testPrice;
  final String userId;   // only userId rakho
  final int serial;
  final bool isDone;
  final DateTime timestamp;

  UsersLabtestModel({
    required this.labID,
    required this.testName,
    required this.testPrice,
    required this.userId,
    required this.serial,
    required this.isDone,
    required this.timestamp,
  });

  factory UsersLabtestModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return UsersLabtestModel(
      labID: doc.id,
      testName: data['testName'] ?? '',
      testPrice: (data['testPrice'] as num).toDouble(),
      userId: data['userId'] ?? '',   // only userId store
      serial: data['serial'] ?? 0,
      isDone: data['isDone'] ?? false,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'testName': testName,
      'testPrice': testPrice,
      'userId': userId,
      'serial': serial,
      'isDone': isDone,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}

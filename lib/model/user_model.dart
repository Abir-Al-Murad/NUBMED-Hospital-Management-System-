import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class medUser {
  final String id;
  final String bloodGroup;
  final bool donor;
  final String email;
  final String location;
  final String name;
  final String phone;
  final String photoUrl;
  final String studentId;

  medUser({
    required this.id,
    required this.bloodGroup,
    required this.donor,
    required this.email,
    required this.location,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.studentId,
  });

  factory medUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return medUser(
      id: doc.id,
      bloodGroup: data['blood_group'] ?? '',
      donor: data['donor'] ?? false,
      email: data['email'] ?? '',
      location: data['location'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photo_url'] ?? '',
      studentId: data['student_id'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'blood_group': bloodGroup,
      'donor': donor,
      'email': email,
      'location': location,
      'name': name,
      'phone': phone,
      'photo_url': photoUrl,
      'student_id': studentId,
    };
  }
}
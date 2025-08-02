import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class Doctor {
  final String? id; // Add document ID field
  final String degree;
  final String designation;
  final String email;
  final String hospital;
  final String imageUrl; // Changed from image_url for consistency
  final String name;
  final String phone;
  final String specialization;
  final String visitingTime;
  final List<String> visitingDays;

  Doctor({
    this.id,
    required this.degree,
    required this.designation,
    required this.email,
    required this.hospital,
    required this.imageUrl,
    required this.name,
    required this.phone,
    required this.specialization,
    required this.visitingTime,
    required this.visitingDays,
  });

  factory Doctor.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Doctor(
      id: doc.id,
      degree: data['degree'] ?? '',
      designation: data['designation'] ?? '',
      email: data['email'] ?? '',
      hospital: data['hospital'] ?? '',
      imageUrl: data['image_url'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      specialization: data['specialization'] ?? '',
      visitingTime: data['visiting_time'] ?? '',
      visitingDays: List<String>.from(data['visiting_days'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'degree': degree,
      'designation': designation,
      'email': email,
      'hospital': hospital,
      'image_url': imageUrl,
      'name': name,
      'phone': phone,
      'specialization': specialization,
      'visiting_time': visitingTime,
      'visiting_days': visitingDays,
    };
  }
}
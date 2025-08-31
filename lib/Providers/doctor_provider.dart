

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubmed/model/doctor_model.dart';

final doctorsProvider = FutureProvider<List<Doctor>>((ref) async {
  final snapshot = await FirebaseFirestore.instance.collection("doctors").get();
  return snapshot.docs
      .map((doc) => Doctor.fromFirestore(doc))
      .toList();
});


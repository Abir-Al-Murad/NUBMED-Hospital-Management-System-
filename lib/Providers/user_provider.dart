// providers/user_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nubmed/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

final userProvider = FutureProvider<medUser>((ref) async {
  final uid = FirebaseAuth.instance.currentUser!.uid;
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  return medUser.fromFirestore(doc);
});

final profileUpdateProvider = StateNotifierProvider<ProfileUpdateNotifier, bool>(
      (ref) => ProfileUpdateNotifier(),
);

class ProfileUpdateNotifier extends StateNotifier<bool> {
  ProfileUpdateNotifier() : super(false);

  Future<void> updateProfile({
    String? phone,
    String? location,
    bool? donor,
    String? photoUrl,
  }) async {
    state = true;
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final updates = <String, dynamic>{};

      if (phone != null) updates['phone'] = phone;
      if (location != null) updates['location'] = location;
      if (donor != null) updates['donor'] = donor;
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updates);
    } finally {
      state = false;
    }
  }
}
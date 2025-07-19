import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';

class CheckAdmin{
  static bool _admin = false;
  static Future<void> isAdmin(String email)async{
    final doc =await FirebaseFirestore.instance.collection('admins').doc(email).get();
    _admin = doc.exists;
  }

  static bool get isAdminUser => _admin;
}
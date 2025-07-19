import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';


class FetchImage{
  static Future<String?> fetchImageUrl(String uid) async {
    final doc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (doc.exists) {
      return doc.data()?["photo_url"];
    }
    return null;
  }
}

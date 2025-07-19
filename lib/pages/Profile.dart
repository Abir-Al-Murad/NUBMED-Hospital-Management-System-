import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nubmed/Authentication/Sign_in.dart';

class Profile extends StatelessWidget {
   Profile({super.key});

   Future<DocumentSnapshot<Map<String,dynamic>>> getUserData()async{
     final uid = FirebaseAuth.instance.currentUser!.uid;
     return await FirebaseFirestore.instance.collection('users').doc(uid).get();
      }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(title: const Text("Profile")),
       body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
         future: getUserData(),
         builder: (context, snapshot) {
           if (snapshot.connectionState == ConnectionState.waiting) {
             return const Center(child: CircularProgressIndicator());
           }

           if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
             return const Center(child: Text("No user data found"));
           }

           final data = snapshot.data!.data()!;
           return Padding(
             padding: const EdgeInsets.all(16.0),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [

                 CircleAvatar(
                   radius: 70,
                 ),

                 Text("${data['name'] ?? 'N/A'}", style: const TextStyle(fontSize: 18,fontWeight: FontWeight.w700)),
                 Text("Email: ${data['email'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 Text("Phone: ${data['phone'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 Text("Student ID: ${data['student_id'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 Text("Blood Group: ${data['blood_group'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 FilledButton(onPressed: ()async{

                   await FirebaseAuth.instance.signOut();
                   Navigator.pushNamedAndRemoveUntil(context, Signinscreen.name, (predicate)=>false);
                 }, child: Text("LogOut"))
               ],
             ),
           );
         },
       ),
     );
   }
}
// if (userCredential.user != null) {
// await _firestore.collection('users').doc(userCredential.user!.uid).set({
// 'name':nameController.text.trim(),
// 'email': emailController.text.trim(),
// 'phone': phoneController.text.trim(),
// 'bloodGroup': bloodGroup,
// 'studentId': studentIdController.text.trim(),
// });
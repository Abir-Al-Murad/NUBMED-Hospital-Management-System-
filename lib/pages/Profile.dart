import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nubmed/Authentication/SignUp_and_Login.dart';

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
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Text("Name: ${data['name'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 Text("Email: ${data['email'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 Text("Phone: ${data['phone'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 Text("Student ID: ${data['studentId'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 Text("Blood Group: ${data['bloodGroup'] ?? 'N/A'}", style: const TextStyle(fontSize: 18)),
                 ElevatedButton(onPressed: ()async{

                   await FirebaseAuth.instance.signOut();
                   Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=>SignUp_and_Login()), (route)=>false );

                 }, child: Text("LogOut"))
               ],
             ),
           );
         },
       ),
     );
   }
}

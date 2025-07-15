import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nubmed/Authentication/SignUp_and_Login.dart';
import 'package:nubmed/WidgetTree.dart';
import 'package:nubmed/pages/HomePage.dart';

void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(NUBMED());
}

class NUBMED extends StatelessWidget {
  NUBMED({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // brightness: Brightness.dark,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: SignUp_and_Login(),
    );
  }
}

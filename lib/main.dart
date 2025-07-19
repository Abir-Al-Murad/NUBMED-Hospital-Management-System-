import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nubmed/Authentication/Sign_in.dart';
import 'package:nubmed/Authentication/sign_up_screen.dart';
import 'package:nubmed/WidgetTree.dart';
import 'package:nubmed/pages/Admin_Pages/AdminHealthTipsPage.dart';
import 'package:nubmed/pages/Admin_Pages/AdminMedicine.dart';
import 'package:nubmed/pages/Doctors_Profile_page.dart';
import 'package:nubmed/pages/HomePage.dart';
import 'package:nubmed/pages/health_tips.dart';
import 'package:nubmed/pages/medicine_page.dart';
import 'package:nubmed/utils/Color_codes.dart';

void main() async {
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

        // scaffoldBackgroundColor:  Color(0xff74E291),
        // scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          color: Color_codes.meddle,
          shadowColor: Colors.black,
          titleTextStyle: TextStyle(color: Colors.white,fontSize: 22,fontWeight: FontWeight.w700),

        ),
        textTheme: GoogleFonts.poppinsTextTheme(
          TextTheme(
            titleLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w700,color: Colors.white),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            fixedSize: Size.fromWidth(double.maxFinite),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: Color_codes.meddle,
            foregroundColor: Colors.white,
          ),
        ),
      ),
      initialRoute: Signinscreen.name,
      routes: {
        Signinscreen.name: (context) => Signinscreen(),
        Homepage.name: (context) => Homepage(),
        WidgetTree.name: (context) => WidgetTree(),
        SignUpScreen.name: (context) => SignUpScreen(),
        MedicinePage.name: (context) => MedicinePage(),
        HealthTips.name: (context) => HealthTips(),
        AdminMedicinePage.name: (context) => AdminMedicinePage(),
        AdminHealthTipsPage.name: (context) => AdminHealthTipsPage(),
        // DoctorsProfilePage.name: (context) => DoctorsProfilePage(),



      },
    );
  }
}

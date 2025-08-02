import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:nubmed/Authentication/Sign_in.dart';
import 'package:nubmed/Authentication/checkAdmin.dart';
import 'package:nubmed/WidgetTree.dart';
import 'package:nubmed/Widgets/screen_background.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  static String name = '/splash-screen';

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Future<void> _navigateBasedOnAuth() async {
    await Future.delayed(const Duration(seconds: 4)); // Splash wait

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      Administrator.isAdmin(user.email!);
      Administrator.isModerator(user.email!);
      Navigator.pushNamedAndRemoveUntil(context, WidgetTree.name, (route) => false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, Signinscreen.name, (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    _navigateBasedOnAuth();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenBackground(
      child: Center(
        child:Image.asset("assets/NUBMED logo.png",height: 300,width: 400,)
        ),

    );
  }
}

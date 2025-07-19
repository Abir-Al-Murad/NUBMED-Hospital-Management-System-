import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/WidgetTree.dart';
import 'package:nubmed/Widgets/screen_background.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/blood_group_class.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  static String name = '/sign-up';

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailTEController = TextEditingController();
  final TextEditingController _passwordTEController = TextEditingController();
  final TextEditingController _nameTEController = TextEditingController();
  final TextEditingController _phoneTEController = TextEditingController();
  final TextEditingController _idTEController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? bloodGroup ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ScreenBackground(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(26),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    "Join With Us",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _nameTEController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: "Name"),

                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _idTEController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(hintText: "Student ID"),

                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _phoneTEController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(hintText: "Phone"),

                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailTEController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(hintText: "Email"),

                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordTEController,
                    obscureText: true,
                    decoration: InputDecoration(hintText: "Password"),
                    validator: (String? value){
                      if((value?.length ?? 0) <6){
                        return 'Enter a valid password';
                      }
                      return null;
                    },

                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: bloodGroup,
                    hint: const Text("Select Blood Group"),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    items: Blood_Group_class.bloodGroups.map((e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(e),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        bloodGroup = value;
                      });
                    },
                  ),




                  const SizedBox(height: 16),

                  FilledButton(
                    onPressed: _onTapSignUpButton,
                    child: Text("Sign Up"),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Column(
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Already have an account?  ",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              letterSpacing: 0.4,
                            ),
                            children: [
                              TextSpan(
                                text: "Sign In",
                                style: TextStyle(
                                  color: Color_codes.meddle,
                                  fontWeight: FontWeight.w700,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = _onTapSignInButton,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future _onTapSignUpButton() async{
    if(_formKey.currentState!.validate()){
      try{
        final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailTEController.text,
          password: _passwordTEController.text,
        );
        final uid = authResult.user!.uid;
        // final fcmToken = await FirebaseMessaging.instance.getToken();
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': "${_nameTEController.text}",
          'student_id':"${_idTEController.text}",
          'phone':"${_phoneTEController.text}",
          'email':"${_emailTEController.text}",
          'blood_group':bloodGroup,
          // 'fcmToken':fcmToken
        }
        );
        Navigator.pushNamedAndRemoveUntil(context, WidgetTree.name, (predicate)=>false);

      }on FirebaseAuthException catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message??"Sign Up Failed"))
        );
      }
    }
  }

  void _onTapSignInButton() {
    Navigator.pop(context);
  }
}

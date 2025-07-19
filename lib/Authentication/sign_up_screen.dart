import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nubmed/Authentication/Sign_in.dart';
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
  ImagePicker imagePicker = ImagePicker();
  XFile? selectedPhoto;

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
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: GestureDetector(
                            onTap: _onTapImagePicker,
                            child: Container(
                              padding:EdgeInsets.symmetric(vertical: 10,horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text("Photo",style: TextStyle(color: Colors.white),),
                            ),
                          ),
                        ),
                        SizedBox(width: 10,),
                        selectedPhoto == null ? Text("Select Photo(Size <1MB)",style: TextStyle(color: Colors.grey),):Text(selectedPhoto!.name,maxLines: 1,overflow: TextOverflow.ellipsis,),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

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

  void _onTapImagePicker()async{
    final XFile? pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if(pickedImage != null){
      setState(() {
        selectedPhoto = pickedImage;
      });
    }
  }

  Future<String?> UploadImageToImgBB(XFile image)async{
    final apiKey = "117a14bd3560bd307339ef10aa2a9323";
    final url = Uri.parse("https://api.imgbb.com/1/upload?key=$apiKey");
    final base64Image = base64Encode(await image.readAsBytes());
    final response = await post(url,body: {
      'image':base64Image,
    });
    if(response.statusCode ==200){
      final data = jsonDecode(response.body);
      return data['data']['url'];
    }else{
      return null;
    }
  }

  Future _onTapSignUpButton() async {
    if (_formKey.currentState!.validate()) {
      if (bloodGroup == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select your blood group.")),
        );
        return;
      }

      if (selectedPhoto == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please select a profile photo.")),
        );
        return;
      }


      final file = XFile(selectedPhoto!.path);
      final fileSize = await file.length(); // in bytes

      if (fileSize > 1024 * 1024) {
        // 1MB
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image size must be less than 1MB.")),
        );
        return;
      }


      final imageUrl = await UploadImageToImgBB(selectedPhoto!);
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed. Try again.")),
        );
        return;
      }

      try {
        final authResult = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: _emailTEController.text.trim(),
          password: _passwordTEController.text,
        );

        final uid = authResult.user!.uid;

        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'name': _nameTEController.text,
          'student_id': _idTEController.text,
          'phone': _phoneTEController.text,
          'email': _emailTEController.text,
          'blood_group': bloodGroup,
          'photo_url': imageUrl,
        });

        Navigator.pushNamedAndRemoveUntil(
            context, Signinscreen.name, (route) => false);
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "Sign Up Failed")),
        );
      }
    }
  }


  void _onTapSignInButton() {
    Navigator.pop(context);
  }
}

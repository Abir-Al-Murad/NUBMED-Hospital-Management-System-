import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nubmed/WidgetTree.dart';

class SignUp_and_Login extends StatefulWidget {
  const SignUp_and_Login({super.key});

  @override
  State<SignUp_and_Login> createState() => _SignUp_and_LoginState();
}

class _SignUp_and_LoginState extends State<SignUp_and_Login> {
  bool isLogin = true;

  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final nameController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final studentIdController = TextEditingController();

  String? bloodGroup;

  final bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool loading = false;



  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    studentIdController.dispose();
    super.dispose();
  }

  void toggleForm() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      loading = true;
    });

    try {
      if (isLogin) {
        // Login user
        final userCredential = await _auth.signInWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());

        if (userCredential.user != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => WidgetTree()),
          );
        }
      } else {
        // Signup user
        final userCredential = await _auth.createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text.trim());

        if (userCredential.user != null) {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name':nameController.text.trim(),
            'email': emailController.text.trim(),
            'phone': phoneController.text.trim(),
            'bloodGroup': bloodGroup,
            'studentId': studentIdController.text.trim(),
          });

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => WidgetTree()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication error')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Something went wrong')),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('NUBMED ${isLogin ? "Login" : "Signup"}'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Email
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (val) =>
                  val != null && val.contains('@') ? null : 'Enter valid email',
                ),
                SizedBox(height: 10),

                // Password
                TextFormField(
                  controller: passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (val) =>
                  val != null && val.length >= 6 ? null : 'Minimum 6 chars required',
                ),
                SizedBox(height: 10),

                // If Signup, show extra fields
                if (!isLogin) ...[
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Name'),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    // validator: (val) =>
                    // val != null && val.length >= 30 ? null : 'Enter valid Name',
                  ),

                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: 'Phone'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,

                    validator: (val) =>
                    val != null && val.length >= 10 ? null : 'Enter valid phone',
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: studentIdController,
                    decoration: InputDecoration(labelText: 'Student ID'),
                    textInputAction: TextInputAction.next,

                    validator: (val) =>
                    val != null && val.isNotEmpty ? null : 'Enter student ID',
                  ),

                  SizedBox(height: 10),

                  DropdownButtonFormField<String>(
                    value: bloodGroup,
                    hint: Text('Select Blood Group'),
                    items: bloodGroups
                        .map((bg) => DropdownMenuItem(value: bg, child: Text(bg)))
                        .toList(),
                    onChanged: (val) => setState(() => bloodGroup = val),
                    validator: (val) => val == null ? 'Select blood group' : null,
                  ),

                  SizedBox(height: 10),
                ],

                SizedBox(height: 20),
                loading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: submit,
                  child: Text(isLogin ? 'Login' : 'Signup'),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: toggleForm,
                  child: Text(isLogin
                      ? 'Don\'t have an account? Signup'
                      : 'Already have an account? Login'),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

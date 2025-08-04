import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nubmed/Authentication/Sign_in.dart';
import 'package:nubmed/Widgets/showsnackBar.dart';
import 'package:nubmed/model/user_model.dart';
import 'package:nubmed/utils/pickImage_imgbb.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _isUploading = false;
  bool _isUpdating = false;
  late Future<medUser> _userFuture;
  String? _tempImageUrl;

  @override
  void initState() {
    super.initState();
    _userFuture = _fetchUserData();
  }

  Future<medUser> _fetchUserData() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return medUser.fromFirestore(doc);
  }

  Future<void> _updateProfile({
    String? phone,
    String? location,
    bool? donor,
    String? photoUrl,
  }) async {
    setState(() => _isUpdating = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final updates = <String, dynamic>{};

      if (phone != null) updates['phone'] = phone;
      if (location != null) updates['location'] = location;
      if (donor != null) updates['donor'] = donor;
      if (photoUrl != null) updates['photo_url'] = photoUrl;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update(updates);

      // Refresh user data
      setState(() {
        _userFuture = _fetchUserData();
        _tempImageUrl = null;
      });

      showsnakBar(context, 'Profile updated successfully', false);
    } catch (e) {
      showsnakBar(context, 'Error updating profile: ${e.toString()}', true);
    } finally {
      setState(() => _isUpdating = false);
    }
  }

  Future<void> _handleImageUpload() async {
    String? imageUrl;
    setState(() => _isUploading = true);
    try {
      final XFile? pickedImage = await ImgBBImagePicker.pickImage();
      if (pickedImage == null) return;

      final response = await ImgBBImagePicker.uploadImage(
        imageFile: pickedImage,
        context: context,
      );
      imageUrl = response!.imageUrl;

      if (imageUrl != null) {
        await _updateProfile(photoUrl: imageUrl);
      } else {
        showsnakBar(context, 'Failed to upload image', false);
      }
    } catch (e) {
      showsnakBar(context, 'Error: ${e.toString()}', false);
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _showUpdateDialog(context),
          ),
        ],
      ),
      body: FutureBuilder<medUser>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text("Failed to load profile data"),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context,
                      Signinscreen.name,
                          (route) => false,
                    ),
                    child: const Text("Sign In"),
                  ),
                ],
              ),
            );
          }

          final user = snapshot.data!;
          final currentImageUrl = _tempImageUrl ?? user.photoUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Profile Picture
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).primaryColor,
                          width: 3,
                        ),
                      ),
                      child: ClipOval(
                        child: _isUploading
                            ? const CircularProgressIndicator()
                            : currentImageUrl.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: currentImageUrl,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                          const CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              _buildDefaultAvatar(),
                        )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white),
                        ),
                        onPressed: _isUploading ? null : _handleImageUpload,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // User Info Card
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _buildInfoRow("Name", user.name),
                        const Divider(),
                        _buildInfoRow("Email", user.email),
                        const Divider(),
                        _buildInfoRow("Phone", user.phone),
                        const Divider(),
                        _buildInfoRow("Student ID", user.studentId),
                        const Divider(),
                        _buildInfoRow("Blood Group", user.bloodGroup),
                        const Divider(),
                        _buildInfoRow("Location", user.location),
                        const Divider(),
                        _buildInfoRow(
                          "Blood Donor",
                          user.donor ? 'Yes' : 'No',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Log Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    label: const Text("Log Out"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        Signinscreen.name,
                            (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showUpdateDialog(BuildContext context) {
    final userFuture = _userFuture;
    final phoneController = TextEditingController();
    final locationController = TextEditingController();
    bool isDonor = false;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<medUser>(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final user = snapshot.data!;
            phoneController.text = user.phone;
            locationController.text = user.location;
            isDonor = user.donor;

            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text("Update Profile"),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: "Phone Number",
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            labelText: "Location",
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Text("Blood Donor"),
                            const Spacer(),
                            Switch(
                              value: isDonor,
                              onChanged: (value) =>
                                  setState(() => isDonor = value),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: _isUpdating
                          ? null
                          : () async {
                        await _updateProfile(
                          phone: phoneController.text,
                          location: locationController.text,
                          donor: isDonor,
                        );
                        if (mounted) Navigator.pop(context);
                      },
                      child: _isUpdating
                          ? const CircularProgressIndicator()
                          : const Text("Update"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            flex: 2,
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return const Icon(
      Icons.person,
      size: 60,
      color: Colors.blueGrey,
    );
  }
}
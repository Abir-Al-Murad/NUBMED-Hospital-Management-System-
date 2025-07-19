import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/utils/Color_codes.dart';

class AdminMedicinePage extends StatefulWidget {
  const AdminMedicinePage({super.key});
  static String name = '/admin-medicine-page';

  @override
  State<AdminMedicinePage> createState() => _AdminMedicinePageState();
}

class _AdminMedicinePageState extends State<AdminMedicinePage> {
  String _searchTerm = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    setState(() {
      _searchTerm = _searchController.text.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchTerm = '';
    });
  }

  void _addOrEditMedicine({DocumentSnapshot? document}) {
    final isEditing = document != null;
    final TextEditingController nameController =
    TextEditingController(text: document?['name'] ?? '');
    final TextEditingController typeController =
    TextEditingController(text: document?['type'] ?? '');
    final TextEditingController manufacturerController =
    TextEditingController(text: document?['manufacturer'] ?? '');
    final TextEditingController usesController =
    TextEditingController(text: document?['uses'] ?? '');
    final TextEditingController dosageController =
    TextEditingController(text: document?['dosage'] ?? '');
    final TextEditingController sideEffectsController =
    TextEditingController(text: document?['side_effects'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isEditing ? "Edit Medicine" : "Add New Medicine"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              _buildTextField("Name", nameController),
              _buildTextField("Type", typeController),
              _buildTextField("Brand/Manufacturer", manufacturerController),
              _buildTextField("Uses", usesController),
              _buildTextField("Dosage", dosageController),
              _buildTextField("Side Effects", sideEffectsController),
            ],
          ),
        ),
        actions: [
          Column(
            children: [
              FilledButton(
                onPressed: () async {
                  final data = {
                    'name': nameController.text.trim(),
                    'type': typeController.text.trim(),
                    'manufacturer': manufacturerController.text.trim(),
                    'uses': usesController.text.trim(),
                    'dosage': dosageController.text.trim(),
                    'side_effects': sideEffectsController.text.trim(),
                  };

                  final collection =
                  FirebaseFirestore.instance.collection('medicines');

                  if (isEditing) {
                    await collection.doc(document!.id).update(data);
                  } else {
                    await collection.add(data);
                  }

                  Navigator.pop(context);
                },
                child: Text(isEditing ? "Update" : "Add"),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),

            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color_codes.meddle),
          border: OutlineInputBorder(),
        ),
      )

    );
  }


  Future<void> _deleteMedicine(String id) async {
    TextEditingController _passwordTEController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Enter your password to confirm deletion"),
              TextField(
                controller: _passwordTEController,
                obscureText: true,
                decoration: const InputDecoration(
                  hintText: "Password",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final password = _passwordTEController.text.trim();
                final user = FirebaseAuth.instance.currentUser;

                if (user != null && user.email != null) {
                  try {
                    final cred = EmailAuthProvider.credential(
                        email: user.email!, password: password);
                    await user.reauthenticateWithCredential(cred);

                    // Password matched — now delete medicine
                    await FirebaseFirestore.instance.collection('medicines').doc(id).delete();

                    Navigator.of(context).pop(); // Close dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Medicine deleted')),
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'wrong-password') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wrong password')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Something went wrong')),
                      );
                    }
                  }
                }
              },
              child: const Text("Confirm"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cancel dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Medicines"),
        centerTitle: true,
        actions: [
          TextButton(onPressed: (){
            _addOrEditMedicine();
          }, child: Text("+ Add",style: TextStyle(fontWeight: FontWeight.w500,color: Colors.white),))
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('medicines').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData) {
            return const Center(child: Text("No Medicine Available"));
          }

          final medicines = snapshot.data!.docs;

          final filteredData = _searchTerm.isEmpty
              ? medicines
              : medicines.where((doc) {
            final name = doc['name'].toString().toLowerCase();
            return name.contains(_searchTerm.toLowerCase());
          }).toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: "Search here",
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: _clearSearch,
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    ElevatedButton(
                      onPressed: _performSearch,
                      child: const Text("Search"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color_codes.meddle,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: filteredData.isEmpty
                    ? const Center(child: Text("No medicine found"))
                    : ListView.builder(
                  itemCount: filteredData.length,
                  itemBuilder: (context, index) {
                    final doc = filteredData[index];
                    final data = doc.data();

                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          data['name'] ?? 'Unknown Medicine',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 6),
                            Text("Type: ${data['type'] ?? 'N/A'}"),
                            Text(
                                "Brand: ${data['manufacturer'] ?? 'N/A'}"),
                            Text("Uses: ${data['uses'] ?? 'N/A'}"),
                            Text("Dose: ${data['dosage'] ?? 'N/A'}"),
                            Text("Side Effects: ${data['side_effects'] ?? 'N/A'}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () =>
                                  _addOrEditMedicine(document: doc),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _deleteMedicine(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

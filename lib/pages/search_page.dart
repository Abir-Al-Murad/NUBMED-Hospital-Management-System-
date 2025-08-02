import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by name, blood group, or student ID',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchText = '';
                    });
                  },
                )
                    : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No users found'));
                }

                final users = snapshot.data!.docs.where((doc) {
                  final user = doc.data() as Map<String, dynamic>;
                  final name = user['name']?.toString().toLowerCase() ?? '';
                  final bloodGroup = user['blood_group']?.toString().toLowerCase() ?? '';
                  final studentId = user['student_id']?.toString().toLowerCase() ?? '';

                  return name.contains(_searchText) ||
                      bloodGroup.contains(_searchText) ||
                      studentId.contains(_searchText);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text('No matching users found'));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index].data() as Map<String, dynamic>;
                    return _buildUserCard(user);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.red[100],
          backgroundImage: user['photo_url']?.isNotEmpty == true
              ? NetworkImage(user['photo_url'])
              : null,
          child: user['photo_url']?.isNotEmpty != true
              ? Text(user['name']?.isNotEmpty == true
              ? user['name'][0].toUpperCase()
              : '?')
              : null,
        ),
        title: Text(
          user['name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Blood Group: ${user['blood_group'] ?? 'Not specified'}'),
            Text('Student ID: ${user['student_id'] ?? 'N/A'}'),
            if (user['phone'] != null) Text('Phone: ${user['phone']}'),
          ],
        ),
        trailing: user['donor'] == true
            ? Chip(
          backgroundColor: Colors.red[50],
          label: const Text('Donor'),
        )
            : null,
        onTap: () {
          // You can add navigation to user details page here
        },
      ),
    );
  }
}
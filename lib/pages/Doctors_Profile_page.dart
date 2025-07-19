import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:nubmed/utils/Color_codes.dart';

class DoctorsProfilePage extends StatefulWidget {
  DoctorsProfilePage({super.key, required this.doctorsData,required this.index});

  final Map<String, dynamic> doctorsData;
  int index;
  static String name = '/doctor-profile';

  @override
  State<DoctorsProfilePage> createState() => _DoctorsProfilePageState();
}

class _DoctorsProfilePageState extends State<DoctorsProfilePage> {
  @override
  Widget build(BuildContext context) {
    final data = widget.doctorsData;

    return Scaffold(
      appBar: AppBar(title: const Text("Doctor Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Hero
            Hero(
              tag: "${data['name']}${widget.index}",
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: CachedNetworkImage(
                  imageUrl: data['image_url'] ?? '',
                  placeholder: (context, url) => Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 220,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.broken_image_rounded,
                          size: 60, color: Colors.grey),
                    ),
                  ),
                  fit: BoxFit.fitHeight,
                  height: 250,
                  width: double.infinity,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name
            _buildTitle("Name"),
            Text(data['name'] ?? '', style: _valueStyle()),

            const SizedBox(height: 16),

            // Degree
            _buildTitle("Degree"),
            Text(data['degree'] ?? '', style: _valueStyle()),

            const SizedBox(height: 16),

            // Designation
            _buildTitle("Designation"),
            Text(data['designation'] ?? '', style: _valueStyle()),

            const SizedBox(height: 16),

            // Hospital
            _buildTitle("Hospital"),
            Text(data['hospital'] ?? '', style: _valueStyle()),

            const SizedBox(height: 16),

            // Specialization
            _buildTitle("Specialization"),
            Text(data['specialization'] ?? '', style: _valueStyle()),

            const SizedBox(height: 16),

            // Visiting Days
            _buildTitle("Visiting Days"),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: (data['visiting_days'] as List<dynamic>? ?? [])
                  .map((day) => Chip(
                label: Text(day),
                backgroundColor: Colors.blue.shade50,
                labelStyle: const TextStyle(color: Colors.black87),
              ))
                  .toList(),
            ),

            const SizedBox(height: 16),

            // Visiting Time
            _buildTitle("Visiting Time"),
            Text(data['visiting_time'] ?? '', style: _valueStyle()),
          ],
        ),
      ),
    );
  }

  TextStyle _valueStyle() {
    return const TextStyle(fontSize: 16, color: Colors.black87);
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        // color: Colors.blueGrey,
        color: Color_codes.deep_plus,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/utils/Color_codes.dart';

class PatientsAppointments extends StatefulWidget {
  const PatientsAppointments({super.key, required this.doctorName});
  final String doctorName;
  static String name = '/patients-appointments';

  @override
  State<PatientsAppointments> createState() => _PatientsAppointmentsState();
}

class _PatientsAppointmentsState extends State<PatientsAppointments> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime? _selectedDate;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Stream<QuerySnapshot> get _filteredAppointments {
    Query query = _firestore.collection('appointments')
        .where('doctorName', isEqualTo: widget.doctorName)
        .orderBy('serialNumber');

    if (_selectedDate != null) {
      final startDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      final endDate = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day, 23, 59, 59);
      query = query
          .where('appointmentDate', isGreaterThanOrEqualTo: startDate)
          .where('appointmentDate', isLessThanOrEqualTo: endDate);
    } else {
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
      query = query
          .where('appointmentDate', isGreaterThanOrEqualTo: todayStart)
          .where('appointmentDate', isLessThanOrEqualTo: todayEnd);
    }

    return query.snapshots();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color_codes.deep_plus,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments - ${widget.doctorName}'),
        centerTitle: true,
        backgroundColor: Color_codes.deep_plus,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _selectDate(context),
            tooltip: 'Filter by date',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_selectedDate != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Showing appointments for: ${DateFormat('MMMM d, y').format(_selectedDate!)}',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color_codes.deep_plus,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        _selectedDate = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filteredAppointments,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 50, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        Text(
                          'No appointments found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final appointment = snapshot.data!.docs[index];
                    final data = appointment.data() as Map<String, dynamic>;
                    final isVisited = data['visited'] == true;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          data['userName'] ?? 'Unknown Patient',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'ID: ${data['student_id'] ?? 'N/A'}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isVisited
                                          ? Colors.green.shade50
                                          : Colors.red.shade50,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isVisited ? 'Visited' : 'Pending',
                                      style: TextStyle(
                                        color: isVisited
                                            ? Colors.green
                                            : Colors.red,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey.shade200),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildInfoItem(
                                    icon: Icons.calendar_today,
                                    text: _formatDate(data['appointmentDate']),
                                    color: Color_codes.deep_plus,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildInfoItem(
                                    icon: Icons.schedule,
                                    text: data['visiting_time'] ?? 'N/A',
                                    color: Colors.blue.shade700,
                                  ),
                                  const SizedBox(width: 16),
                                  _buildInfoItem(
                                    icon: Icons.format_list_numbered,
                                    text: 'Serial: ${data['serialNumber']}',
                                    color: Colors.orange.shade700,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle, size: 18),
                                      label: const Text('Mark Visited'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color_codes.deep_plus,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _updateAppointmentStatus(appointment.id, true),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.cancel, size: 18),
                                      label: const Text('Mark Absent'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade600,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                      onPressed: () =>
                                          _updateAppointmentStatus(appointment.id, false),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is Timestamp) {
      return DateFormat('MMM d').format(date.toDate());
    }
    return date.toString();
  }

  Future<void> _updateAppointmentStatus(
      String appointmentId, bool visited) async {
    try {
      await _firestore.collection('appointments').doc(appointmentId).update({
        'visited': visited,
        'processedBy': _auth.currentUser?.uid,
        'processedAt': FieldValue.serverTimestamp(),
      });

      await _sendNotificationToPatient(appointmentId, visited);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Appointment marked as ${visited ? 'Visited' : 'Absent'}'),
          backgroundColor: visited ? Colors.green : Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendNotificationToPatient(
      String appointmentId, bool visited) async {
    final appointment = await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .get();
    final patientId = appointment.data()?['userId'];

    if (patientId != null) {
      await _firestore.collection('notifications').add({
        'userId': patientId,
        'title': 'Appointment Status',
        'message':
        'Your appointment has been marked as ${visited ? 'Visited' : 'Absent'}',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });
    }
  }
}
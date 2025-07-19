import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/pages/Doctors_Profile_page.dart';
import 'package:nubmed/utils/Color_codes.dart';
import 'package:nubmed/utils/specialization_list.dart';

class DoctorPage extends StatefulWidget {
  const DoctorPage({super.key});

  @override
  State<DoctorPage> createState() => _DoctorPageState();
}

class _DoctorPageState extends State<DoctorPage> {
  DoctorSpecialization? selectedSpecialization;

  Future<DateTime?> showDoctorAppointmentPicker(
      BuildContext context,
      List<String> availableDays,
      String visitingTime,
      ) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime startOfThisWeek = today.subtract(Duration(days: today.weekday - 1));
    final DateTime endOfNextWeek = startOfThisWeek.add(const Duration(days: 13));

    DateTime? firstAvailableDate;
    for (int i = 0; i <= 13; i++) {
      final candidate = today.add(Duration(days: i));
      final dayName = DateFormat('EEEE').format(candidate);
      if (availableDays.contains(dayName)) {
        if (i == 0) {
          try {
            final parsedTime = DateFormat.jm().parse(visitingTime);
            final visitingToday = DateTime(
              candidate.year,
              candidate.month,
              candidate.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            if (now.isBefore(visitingToday)) {
              firstAvailableDate = candidate;
              break;
            }
          } catch (_) {}
        } else {
          firstAvailableDate = candidate;
          break;
        }
      }
    }

    if (firstAvailableDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No available appointment days left")),
      );
      return null;
    }

    return await showDatePicker(
      context: context,
      initialDate: firstAvailableDate,
      firstDate: today,
      lastDate: endOfNextWeek,
      selectableDayPredicate: (date) {
        final dayName = DateFormat('EEEE').format(date);
        if (!availableDays.contains(dayName)) return false;
        if (DateUtils.isSameDay(date, today)) {
          try {
            final parsedTime = DateFormat.jm().parse(visitingTime);
            final visitingToday = DateTime(
              date.year,
              date.month,
              date.day,
              parsedTime.hour,
              parsedTime.minute,
            );
            return now.isBefore(visitingToday);
          } catch (_) {
            return false;
          }
        }
        return true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Our Doctors"), centerTitle: true),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text("Something went wrong"));
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final filteredDocs = (selectedSpecialization == null || selectedSpecialization!.displayName == 'All')
              ? docs
              : docs.where((e) {
            final data = e.data() as Map<String, dynamic>;
            return data['specialization'] == selectedSpecialization!.displayName;
          }).toList();

          if (docs.isEmpty) return const Center(child: Text("No doctors available"));

          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5.0),
                DropdownButtonFormField<DoctorSpecialization>(
                  value: selectedSpecialization,
                  hint: const Text("Select Specialization", style: TextStyle(fontSize: 14.0)),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Color_codes.meddle, width: 1.5),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Color_codes.meddle, width: 1.5),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(color: Color_codes.meddle, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 12.0),
                  ),
                  items: DoctorSpecialization.values
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e.displayName, style: const TextStyle(fontSize: 12.0)),
                  ))
                      .toList(),
                  onChanged: (value) => setState(() => selectedSpecialization = value),
                ),
                const SizedBox(height: 12.0),
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredDocs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio: 0.55,
                    ),
                    itemBuilder: (context, index) {
                      final doctor = filteredDocs[index].data() as Map<String, dynamic>;
                      final List<dynamic> availableDays = doctor['visiting_days'] ?? [];
                      final isAvailable = isDoctorAvailableToday(availableDays, doctor['visiting_time']);

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorsProfilePage(
                              doctorsData: doctor,
                              index: index,
                            ),
                          ),
                        ),
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 6,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Hero(
                                tag: "${doctor['name']}$index",
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14.0)),
                                  child: CachedNetworkImage(
                                    imageUrl: doctor['image_url'] ?? 'https://default-image-url',
                                    height: 160.0,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      height: 115.0,
                                      color: Colors.grey[300],
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error, size: 28.0),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        doctor['name'] ?? 'Unknown',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.0),
                                      ),
                                      const SizedBox(height: 2.0),
                                      Text(
                                        doctor['degree'] ?? '',
                                        style: TextStyle(fontSize: 10.0, color: Colors.grey[600]),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        doctor['specialization'] ?? '',
                                        style: TextStyle(fontSize: 10.0, color: Colors.grey[700]),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6.0),
                                      Text(
                                        'Visiting Time: ${doctor['visiting_time'] ?? ''}',
                                        style: TextStyle(fontSize: 10.0, color: Colors.grey[700]),
                                      ),
                                      const SizedBox(height: 6.0),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                                        decoration: BoxDecoration(
                                          color: isAvailable ? Colors.green[50] : Colors.red[50],
                                          borderRadius: BorderRadius.circular(6.0),
                                        ),
                                        child: Text(
                                          isAvailable ? "Available Today" : "Not Available Today",
                                          style: TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w600,
                                            color: isAvailable ? Colors.green : Colors.red,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8.0),
                                          ),
                                        ),
                                        onPressed: () async {
                                          final selectedDate = await showDoctorAppointmentPicker(
                                            context,
                                            List<String>.from(doctor['visiting_days'] ?? []),
                                            doctor['visiting_time'] ?? "12:00 PM",
                                          );

                                          if (selectedDate == null) return;

                                          final querySnapshot = await FirebaseFirestore.instance
                                              .collection('appointments')
                                              .where('doctorName', isEqualTo: doctor['name'])
                                              .where('appointmentDate', isEqualTo: selectedDate)
                                              .get();

                                          await FirebaseFirestore.instance.collection('appointments').add({
                                            'doctorName': doctor['name'],
                                            'userId': FirebaseAuth.instance.currentUser!.uid,
                                            'userName': FirebaseAuth.instance.currentUser!.displayName,
                                            'appointmentDate': selectedDate,
                                            'timestamp': FieldValue.serverTimestamp(),
                                            'serialNumber': querySnapshot.docs.length + 1,
                                            'visiting_time': doctor['visiting_time'],
                                          });

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                "Your Appointment Confirmed on ${DateFormat("d MMMM").format(selectedDate)} at ${doctor['visiting_time']}",
                                                style: const TextStyle(fontSize: 12.0),
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text("Make Appointment", style: TextStyle(fontSize: 12.0)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
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

  bool isDoctorAvailableToday(List<dynamic> availableDays, String visitingTime) {
    final now = DateTime.now();
    final todayName = DateFormat('EEEE').format(now);
    if (!availableDays.contains(todayName)) return false;
    try {
      final visitingDateTime = DateFormat.jm().parse(visitingTime);
      final todayVisitingTime = DateTime(now.year, now.month, now.day, visitingDateTime.hour, visitingDateTime.minute);
      return now.isBefore(todayVisitingTime);
    } catch (e) {
      return false;
    }
  }
}

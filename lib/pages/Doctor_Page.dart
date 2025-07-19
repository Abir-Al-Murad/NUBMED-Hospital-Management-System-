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

    // Find the first valid date
    DateTime? firstAvailableDate;
    for (int i = 0; i <= 13; i++) {
      final candidate = today.add(Duration(days: i));
      final dayName = DateFormat('EEEE').format(candidate);

      // 🛑 Today only allowed if visiting time is not passed
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
          if (snapshot.hasError) {
            return const Center(child: Text("Something went wrong"));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;


          final filteredDocs = (selectedSpecialization == null) || (selectedSpecialization!.displayName == 'All')
              ? docs
              : docs.where((e) {
                  final data = e.data() as Map<String, dynamic>;
                  return data['specialization'] ==
                      selectedSpecialization!.displayName;
                }).toList();
          if (docs.isEmpty) {
            return const Center(child: Text("No doctors available"));
          }

          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                SizedBox(height: 5,),
                DropdownButtonFormField<DoctorSpecialization>(
                  value: selectedSpecialization,
                  hint: const Text("Select Specialization"),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color_codes.meddle,
                        width: 1.5,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color_codes.meddle,
                        width: 1.5,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: Color_codes.meddle,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  items: DoctorSpecialization.values
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(e.displayName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedSpecialization = value;
                    });
                  },
                ),

                SizedBox(height: 14),
                Expanded(
                  child: GridView.builder(
                    itemCount: filteredDocs.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.5,
                        ),
                    itemBuilder: (context, index) {
                      final doctor =
                          filteredDocs[index].data() as Map<String, dynamic>;
                      final List<dynamic> availableDays =
                          doctor['visiting_days'] ?? [];

                      final isAvailable = isDoctorAvailableToday(availableDays,doctor['visiting_time']);

                      return GestureDetector(
                        onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder: (context)=>DoctorsProfilePage(doctorsData: doctor, index: index)));
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                                Hero(

                                  tag: "${doctor['name']}$index}",
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: CachedNetworkImage(
                                      imageUrl:
                                          doctor['imageUrl'] ??
                                          'https://default-image-url',
                                      height: 130,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      placeholder: (context, url) => Container(
                                        height: 130,
                                        color: Colors.grey[300],
                                      ),
                                      errorWidget: (context, url, error) =>
                                          const Icon(Icons.error, size: 60),
                                    ),
                                  ),
                                ),

                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor['name'] ?? 'Unknown',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        doctor['degree'] ?? '',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),

                                      const SizedBox(height: 8),
                                      Text(
                                        doctor['specialization'] ?? '',

                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Visiting Time: ${doctor['visiting_time'] ?? ''}',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      const SizedBox(height: 8),

                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isAvailable
                                              ? Colors.green[50]
                                              : Colors.red[50],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          isAvailable
                                              ? "Available Today"
                                              : "Not Available Today",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: isAvailable
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
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
                                            SnackBar(content: Text("Your Appointment Confirmed on ${DateFormat("d MMMM").format(selectedDate)} at ${doctor['visiting_time']}"))
                                          );
                                        },

                                        child: const Text("Make Appointment"),
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
    final todayName = DateFormat('EEEE').format(now); // e.g., "Wednesday"

    if (!availableDays.contains(todayName)) return false;

    // Parse visiting time like "3:00 PM"
    try {
      final visitingDateTime = DateFormat.jm().parse(visitingTime); // parses to today's time

      final todayVisitingTime = DateTime(
        now.year,
        now.month,
        now.day,
        visitingDateTime.hour,
        visitingDateTime.minute,
      );

      return now.isBefore(todayVisitingTime); // true = still available
    } catch (e) {
      return false;
    }
  }

  //  _onTapProfile(Map<String,dynamic> doctorsData){
  //   Navigator.pushNamed(context, DoctorsProfilePage.name,arguments: doctorsData);
  // }

}

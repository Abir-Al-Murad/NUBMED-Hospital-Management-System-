// providers/appointment_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nubmed/model/appointment_model.dart';
import 'package:nubmed/model/doctor_model.dart';
import 'user_provider.dart';
import 'package:flutter/material.dart';

final appointmentServiceProvider = Provider<AppointmentService>((ref) {
  return AppointmentService(ref);
});

class AppointmentService {
  final Ref ref;
  AppointmentService(this.ref);

  Future<DateTime?> showDoctorAppointmentPicker(
      BuildContext context,
      List<String> availableDays,
      String visitingTime,
      ) async {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime endOfNextWeek = today.add(const Duration(days: 13));

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

  bool isDoctorAvailableToday(List<dynamic> availableDays) {
    try {
      final now = DateTime.now();
      final todayName = DateFormat('EEEE').format(now);
      final availableDayNames = availableDays
          .map((day) => day.toString().toLowerCase())
          .toList();
      return availableDayNames.contains(todayName.toLowerCase());
    } catch (_) {
      return false;
    }
  }

  Future<void> bookAppointment(BuildContext context, Doctor doctor) async {
    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      final currentUser = auth.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("You must be logged in")));
        return;
      }

      final user = await ref.read(userProvider.future);

      final selectedDate = await showDoctorAppointmentPicker(
        context,
        doctor.visitingDays,
        doctor.visitingTime,
      );
      if (selectedDate == null) return;

      final existing = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctor.id)
          .where('userId', isEqualTo: user.id)
          .where(
        'appointmentDate',
        isGreaterThanOrEqualTo: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ),
      )
          .where(
        'appointmentDate',
        isLessThan: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day + 1,
        ),
      )
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("You already have an appointment today")));
        return;
      }

      final time = DateFormat.jm().parse(doctor.visitingTime);
      final appointmentDateTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        time.hour,
        time.minute,
      );

      final appointments = await firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: doctor.id)
          .where(
        'appointmentDate',
        isGreaterThanOrEqualTo: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
        ),
      )
          .where(
        'appointmentDate',
        isLessThan: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day + 1,
        ),
      )
          .get();

      final appointment = Appointment(
        id: '',
        appointmentDate: appointmentDateTime,
        doctorId: doctor.id!,
        doctorName: doctor.name,
        doctorSpecialization: doctor.specialization,
        serialNumber: appointments.docs.length + 1,
        timestamp: DateTime.now(),
        userId: user.id,
        userName: user.name,
        userPhone: user.phone,
        userStudentId: user.studentId,
        visited: false,
        visitingTime: doctor.visitingTime,
      );

      await firestore.collection('appointments').add(appointment.toFirestore());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Appointment booked for ${DateFormat('MMMM d').format(selectedDate)} at ${doctor.visitingTime}'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}

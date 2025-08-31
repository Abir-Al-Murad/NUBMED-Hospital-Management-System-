import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore firestore = FirebaseFirestore.instance;

Future<void> addDoctorData() async {
  CollectionReference doctors = firestore.collection('doctors');

  final doctorList = [
    {
      "name": "Dr. Mohammad Shahjahan Islam",
      "specialization": "General & Cancer Surgery",
      "degree": "MBBS (DU), BCS (Health), FCPS (Surgery)",
      "designation": "Consultant, Surgery Department",
      "hospital": "National Institute of Cancer Research & Hospital, Mohakhali, Dhaka",
      "visiting_days": ["Saturday", "Monday", "Wednesday"],
      "visiting_time": "3:00 PM",
      "image_url": ""
    },
    {
      "name": "Dr. Anowar Hossain",
      "specialization": "Orthopedic & Trauma",
      "degree": "MBBS (DU), BCS (Health), D-Ortho (NITOR), MS (Orthopedic)",
      "designation": "Assistant Professor",
      "hospital": "Shaheed Suhrawardy Medical College Hospital, Dhaka",
      "visiting_days": ["Friday"],
      "visiting_time": "10:00 AM",
      "image_url": ""
    },
    {
      "name": "Prof. Dr. Md. Aminul Islam Shikdar",
      "specialization": "General & Laparoscopic Surgery",
      "degree": "MBBS (DU), FCPS (Surgery)",
      "designation": "Former Professor and Head, Surgery Department",
      "hospital": "Shaheed Suhrawardy Medical College Hospital, Dhaka",
      "visiting_days": ["Friday"],
      "visiting_time": "10:00 AM",
      "image_url": ""
    },
    {
      "name": "Dr. Noor Mohammad Sayeed Bin Aziz",
      "specialization": "ENT, Head-Neck & Thyroid Surgery",
      "degree": "MBBS (DU), MS (ENT & Head-Neck Surgery)",
      "designation": "ENT Specialist",
      "hospital": "BSMMU, Dhaka",
      "visiting_days": ["Friday"],
      "visiting_time": "10:00 AM",
      "image_url": ""
    },
    {
      "name": "Dr. Md. Shafiqul Islam",
      "specialization": "General & Laparoscopic Surgery",
      "degree": "MBBS (DU), BCS (Health), FCPS (Surgery)",
      "designation": "Consultant, Surgery Department",
      "hospital": "Shaheed Suhrawardy Medical College Hospital, Dhaka",
      "visiting_days": ["Friday"],
      "visiting_time": "10:30 AM",
      "image_url": ""
    },
    {
      "name": "Dr. Sonia Rahman",
      "specialization": "General & Laparoscopic Surgery",
      "degree": "MBBS (Dhaka), FCPS (Surgery)",
      "designation": "Consultant, Surgery Department",
      "hospital": "Ibn Sina Hospital, Mohakhali, Dhaka",
      "visiting_days": ["Sunday"],
      "visiting_time": "4:30 PM",
      "image_url": ""
    },
    {
      "name": "Dr. Md. Moniruzzaman",
      "specialization": "Respiratory & Medicine",
      "degree": "MBBS, BCS (Health), DTCD, MD (Respiratory Medicine)",
      "designation": "Consultant, Medicine Department",
      "hospital": "Ibn Sina Hospital, Mohakhali, Dhaka",
      "visiting_days": ["Friday", "Saturday", "Monday"],
      "visiting_time": "4:30 PM",
      "image_url": ""
    },
    {
      "name": "Dr. Forhad Hossain",
      "specialization": "Medicine",
      "degree": "MBBS (DU), BCS (Health), FCPS (Medicine)",
      "designation": "Assistant Professor",
      "hospital": "Shaheed Suhrawardy Medical College Hospital, Dhaka",
      "visiting_days": ["Monday", "Wednesday"],
      "visiting_time": "4:30 PM",
      "image_url": ""
    }
  ];

  for (var doctor in doctorList) {
    await doctors.add(doctor);
  }
}

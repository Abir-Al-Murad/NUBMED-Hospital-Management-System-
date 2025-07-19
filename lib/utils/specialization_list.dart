enum DoctorSpecialization {
  all,
  generalCancerSurgery,
  orthopedicTrauma,
  generalLaparoscopicSurgery,
  entHeadNeckThyroid,
  respiratoryMedicine,
  medicine,
  cardiology,
  dermatology,
  gynecology,
  pediatrics,
  nephrology,
  neurology,
  ophthalmology,
  psychiatry,
  rheumatology,
  endocrinology,
  oncology,
}


extension DoctorSpecializationExtension on DoctorSpecialization {
  String get displayName {
    switch (this) {
      case DoctorSpecialization.generalCancerSurgery:
        return "General & Cancer Surgery";
      case DoctorSpecialization.orthopedicTrauma:
        return "Orthopedic & Trauma";
      case DoctorSpecialization.generalLaparoscopicSurgery:
        return "General & Laparoscopic Surgery";
      case DoctorSpecialization.entHeadNeckThyroid:
        return "ENT, Head-Neck & Thyroid Surgery";
      case DoctorSpecialization.respiratoryMedicine:
        return "Respiratory & Medicine";
      case DoctorSpecialization.medicine:
        return "Medicine";
      case DoctorSpecialization.cardiology:
        return "Cardiology";
      case DoctorSpecialization.dermatology:
        return "Dermatology & Venereology";
      case DoctorSpecialization.gynecology:
        return "Gynecology & Obstetrics";
      case DoctorSpecialization.pediatrics:
        return "Pediatrics";
      case DoctorSpecialization.nephrology:
        return "Nephrology";
      case DoctorSpecialization.neurology:
        return "Neurology";
      case DoctorSpecialization.ophthalmology:
        return "Ophthalmology";
      case DoctorSpecialization.psychiatry:
        return "Psychiatry";
      case DoctorSpecialization.rheumatology:
        return "Rheumatology";
      case DoctorSpecialization.endocrinology:
        return "Endocrinology & Diabetes";
      case DoctorSpecialization.oncology:
        return "Oncology (Cancer Specialist)";
      case DoctorSpecialization.all:
        return "All";
    }
  }
}


class NextOfKinModel {
  final String name;
  final String relationship;
  final String phone;

  NextOfKinModel({
    required this.name,
    required this.relationship,
    required this.phone,
  });

  factory NextOfKinModel.fromJson(Map<String, dynamic> json) {
    return NextOfKinModel(
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class AcademicRecordModel {
  final String currentGpa;
  final String currentCpa;
  final int creditsObtained;
  final int creditsTotal;
  final String outstandingDebt;
  final int currentWeek;
  final int totalWeeks;

  AcademicRecordModel({
    required this.currentGpa,
    required this.currentCpa,
    required this.creditsObtained,
    required this.creditsTotal,
    required this.outstandingDebt,
    required this.currentWeek,
    required this.totalWeeks,
  });

  factory AcademicRecordModel.fromJson(Map<String, dynamic> json) {
    return AcademicRecordModel(
      currentGpa: json['current_gpa'] ?? '-',
      currentCpa: json['current_cpa'] ?? '-',
      creditsObtained: json['credits_obtained'] ?? 0,
      creditsTotal: json['credits_total'] ?? 0,
      outstandingDebt: json['outstanding_debt'] ?? '-',
      currentWeek: json['current_week'] ?? 0,
      totalWeeks: json['total_weeks'] ?? 0,
    );
  }
}

class ProfileModel {
  final String matricNo;
  final String fullName;
  final String faculty;
  final String course;
  final String email;
  final String phone;
  final String sessionEnroll;
  final NextOfKinModel? nextOfKin;
  final AcademicRecordModel? academic;

  ProfileModel({
    required this.matricNo,
    required this.fullName,
    required this.faculty,
    required this.course,
    required this.email,
    required this.phone,
    required this.sessionEnroll,
    this.nextOfKin,
    this.academic,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      matricNo: json['matric_no'] ?? '',
      fullName: json['full_name'] ?? '',
      faculty: json['faculty'] ?? '',
      course: json['course'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      sessionEnroll: json['session_enroll'] ?? '',
      nextOfKin: json['next_of_kin'] != null
          ? NextOfKinModel.fromJson(json['next_of_kin'])
          : null,
      academic: json['academic'] != null
          ? AcademicRecordModel.fromJson(json['academic'])
          : null,
    );
  }
}
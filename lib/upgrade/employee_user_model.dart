import 'dart:typed_data';

class EmployeeUser {
  final String id;
  final String workType;
  final String? resumeName;
  final Uint8List? resumeBytes;
  final bool noPanCard;
  final String? panNumber;
  final String? addressProofType;
  final String? addressProofName;
  final String? salaryAccount;
  final String? educationBoard;
  final String? primaryStudy;
  final String? after10thPath;
  final List<EmployeeDegreeData> degrees;

  EmployeeUser({
    required this.id,
    required this.workType,
    this.resumeName,
    this.resumeBytes,
    this.noPanCard = false,
    this.panNumber,
    this.addressProofType,
    this.addressProofName,
    this.salaryAccount,
    this.educationBoard,
    this.primaryStudy,
    this.after10thPath,
    this.degrees = const [],
  });
}

class EmployeeDegreeData {
  final String? stream;
  final String? degree;
  final String? university;
  final String? institute;
  final String? year;

  EmployeeDegreeData({
    this.stream,
    this.degree,
    this.university,
    this.institute,
    this.year,
  });
}

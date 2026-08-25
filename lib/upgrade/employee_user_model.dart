import 'dart:typed_data';

class EmployeeUser {
  final String id;
  final String workType;
  final String? resumeName;
  final String? resumePath;
  final Uint8List? resumeBytes;
  final String? frontPhotoPath;
  final Uint8List? frontPhotoBytes;
  final String? primaryMarksheetPath;
  final Uint8List? primaryMarksheetBytes;
  final String? hsMarksheetPath;
  final Uint8List? hsMarksheetBytes;
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
    this.resumePath,
    this.resumeBytes,
    this.frontPhotoPath,
    this.frontPhotoBytes,
    this.primaryMarksheetPath,
    this.primaryMarksheetBytes,
    this.hsMarksheetPath,
    this.hsMarksheetBytes,
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
  final String? certificatePath;
  final Uint8List? certificateBytes;

  EmployeeDegreeData({
    this.stream,
    this.degree,
    this.university,
    this.institute,
    this.year,
    this.certificatePath,
    this.certificateBytes,
  });
}

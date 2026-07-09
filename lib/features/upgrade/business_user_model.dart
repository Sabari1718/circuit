import 'dart:typed_data';

class PartnerModel {
  final String name;
  final String panNumber;
  final String accessLevel;
  final String? partnershipDealFileName;
  final Uint8List? partnershipDealFileBytes;
  final String? writtenLetterFileName;
  final Uint8List? writtenLetterFileBytes;

  PartnerModel({
    required this.name,
    required this.panNumber,
    required this.accessLevel,
    this.partnershipDealFileName,
    this.partnershipDealFileBytes,
    this.writtenLetterFileName,
    this.writtenLetterFileBytes,
  });
}

class BusinessUser {
  final String id;
  final String? registrationType; // Propagator, Partner, etc.
  final String businessName;
  final String email;
  final String phone;
  final String? website;

  // PAN Identification
  final String panNumber;
  final String? panFileName;
  final Uint8List? panFileBytes;

  // Signature Photo
  final String? signatureFileName;
  final Uint8List? signatureFileBytes;

  // GST Identification
  final String gstNumber;
  final String? gstFileName;
  final Uint8List? gstFileBytes;

  // Bank Info
  final String accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? accountHolderName;
  final String bankDocType; // Bank Statement, etc.
  final String? bankDocFileName;
  final Uint8List? bankDocFileBytes;

  // Address
  final String doorNumber;
  final String streetName;
  final String? buildingName;
  final String? landmark;
  final String area;
  final String district;
  final String pincode;
  final String state;
  final String country;

  // Business Profile
  final List<String> businessTypes;
  final String yearOfEstablishment;
  final String employeeRange;
  final int partnerCount;
  final List<PartnerModel>? partners; // New field for detailed partner info
  final String? sectorTitle;
  final String? sector;
  final String? subSector;
  final List<String>? categories;
  final DateTime createdDate;
  final String status;

  BusinessUser({
    required this.id,
    this.registrationType,
    required this.businessName,
    required this.email,
    required this.phone,
    this.website,
    required this.panNumber,
    this.panFileName,
    this.panFileBytes,
    this.signatureFileName,
    this.signatureFileBytes,
    required this.gstNumber,
    this.gstFileName,
    this.gstFileBytes,
    required this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.accountHolderName,
    required this.bankDocType,
    this.bankDocFileName,
    this.bankDocFileBytes,
    required this.doorNumber,
    required this.streetName,
    this.buildingName,
    this.landmark,
    required this.area,
    required this.district,
    required this.pincode,
    required this.state,
    required this.country,
    required this.businessTypes,
    required this.yearOfEstablishment,
    required this.employeeRange,
    this.partnerCount = 0,
    this.partners,
    required this.createdDate,
    required this.status,
    this.sectorTitle,
    this.sector,
    this.subSector,
    this.categories,
  });
}

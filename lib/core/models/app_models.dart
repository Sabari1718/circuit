import 'dart:typed_data';
import 'package:flutter/material.dart';

// --- Shared Models ---

class PartnerModel {
  final String name;
  final String panNumber;
  final String accessLevel;
  String? partnershipDealFileName;
  Uint8List? partnershipDealFileBytes;
  String? writtenLetterFileName;
  Uint8List? writtenLetterFileBytes;

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
  final String? registrationType; // Propagator, Partner, Supplier
  final String businessName;
  final String email;
  final String phone;
  final String? website;

  // PAN Identification
  final String panNumber;
  final String? panFileName;
  final Uint8List? panFileBytes;

  // Signature
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
  final String bankDocType;
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
  final List<PartnerModel>? partners;
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

class BusinessUserStore extends ChangeNotifier {
  static final BusinessUserStore _instance = BusinessUserStore._internal();
  factory BusinessUserStore() => _instance;
  BusinessUserStore._internal();

  final List<BusinessUser> _businesses = [];
  List<BusinessUser> get businesses => List.unmodifiable(_businesses);

  void addBusiness(BusinessUser business) {
    _businesses.add(business);
    notifyListeners();
  }

  void updateBusiness(BusinessUser updatedBusiness) {
    final index = _businesses.indexWhere((b) => b.id == updatedBusiness.id);
    if (index != -1) {
      _businesses[index] = updatedBusiness;
      notifyListeners();
    }
  }

  BusinessUser? getBusinessById(String id) {
    try {
      return _businesses.firstWhere((b) => b.id == id);
    } catch (e) {
      return null;
    }
  }
}

class BusinessRegistrationData {
  String panNumber = "";
  Uint8List? panFrontBytes;
  Uint8List? profilePhotoBytes;
  String accountNumber = "";
  String? bankDocType;
  Uint8List? bankDocBytes;
  String? bankDocFileName;
  String? addressDocType;
  Uint8List? addressDocBytes;
  String addressTypeMode = "Standard";
  String? standardAddressType;
  String doorNumber = "";
  String streetName = "";
  String buildingName = "";
  String landmark = "";
  String areaName = "";
  String district = "";
  String pincode = "";
  String state = "";
  String country = "India";
}

class JobModel {
  final String title;
  final String company;
  final String location;
  final String type;
  final String salary;
  final String postedDate;

  JobModel({
    required this.title,
    required this.company,
    required this.location,
    required this.type,
    required this.salary,
    required this.postedDate,
  });
}

import 'dart:typed_data';
import 'dart:convert';

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
  final String? actualId;
  final String? registrationType; // Propagator, Partner, etc.
  final String businessName;
  final String email;
  final String phone;
  final String? website;
  final String? companyLogoFileName;
  final Uint8List? companyLogoBytes;
  final String? turnoverRange;

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
  
  final String? addressDocType;
  final String? addressDocFileName;

  // Address
  final String? addressType;
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
    this.actualId,
    this.registrationType,
    required this.businessName,
    required this.email,
    required this.phone,
    this.website,
    this.companyLogoFileName,
    this.companyLogoBytes,
    this.turnoverRange,
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
    this.addressDocType,
    this.addressDocFileName,
    this.addressType,
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

  factory BusinessUser.fromJson(Map<String, dynamic> json) {
    // Determine type formatting (API returns 'supplier', we want 'Supplier')
    String? apiType = json['type']?.toString();
    String? regType = apiType != null && apiType.isNotEmpty
        ? apiType[0].toUpperCase() + apiType.substring(1).toLowerCase()
        : null;

    // Parse business types
    List<String> bTypes = [];
    if (json['business_types'] != null) {
      if (json['business_types'] is String) {
        try {
          final decoded = jsonDecode(json['business_types']);
          if (decoded is List) bTypes = decoded.map((e) => e.toString()).toList();
        } catch (_) {}
      } else if (json['business_types'] is List) {
        bTypes = (json['business_types'] as List).map((e) => e.toString()).toList();
      }
    }

    return BusinessUser(
      id: json['business_id']?.toString() ?? json['id']?.toString() ?? '',
      actualId: json['id']?.toString(),
      registrationType: regType,
      businessName: json['business_name']?.toString() ?? '',
      email: json['business_email']?.toString() ?? '',
      phone: json['business_phone']?.toString() ?? '',
      website: json['website']?.toString(),
      panNumber: json['pan_number']?.toString() ?? json['pan']?.toString() ?? '',
      gstNumber: json['gst_number']?.toString() ?? json['gst']?.toString() ?? '',
      accountNumber: json['current_account_number']?.toString() ?? json['bank_account_number']?.toString() ?? '',
      bankDocType: json['bank_document_type']?.toString() ?? 'statement',
      doorNumber: json['door_number']?.toString() ?? '',
      streetName: json['street_name']?.toString() ?? '',
      buildingName: json['building_name']?.toString(),
      landmark: json['landmark']?.toString(),
      area: json['area']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      state: json['state']?.toString() ?? '',
      country: json['country']?.toString() ?? 'India',
      businessTypes: bTypes,
      yearOfEstablishment: json['year_of_establishment']?.toString() ?? '',
      employeeRange: json['employee_count']?.toString() ?? '',
      partnerCount: int.tryParse(json['partner_count']?.toString() ?? '0') ?? 0,
      createdDate: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      status: json['status']?.toString() ?? 'Active',
      sectorTitle: json['sector_title']?.toString(),
      sector: json['sector']?.toString(),
      subSector: json['sub_sector']?.toString(),
      companyLogoFileName: json['company_logo']?.toString() ?? json['profile_photo']?.toString(),
      panFileName: json['pan_front_photo']?.toString(),
      bankDocFileName: json['bank_document']?.toString(),
      addressDocType: json['address_doc_type']?.toString(),
      addressDocFileName: json['address_proof']?.toString(),
      addressType: json['address_type']?.toString() ?? json['customer_address_type']?.toString(),
    );
  }
}


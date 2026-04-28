import 'dart:typed_data';

class BusinessRegistrationData {
  // Step 1: Personal Details
  String panNumber = "";
  Uint8List? panFrontBytes;
  Uint8List? profilePhotoBytes;

  // Step 2: Bank Account
  String accountNumber = "";

  // Step 3: Bank Document
  String? bankDocType;
  Uint8List? bankDocBytes;
  String? bankDocFileName;

  // Step 4: Address Details
  String? addressDocType;
  Uint8List? addressDocBytes;
  String addressTypeMode = "Standard"; // Standard or Custom
  String? standardAddressType; // Residential, etc.

  String doorNumber = "";
  String streetName = "";
  String buildingName = "";
  String landmark = "";
  String areaName = "";
  String district = "";
  String pincode = "";
  String state = "";
  String country = "India";

  BusinessRegistrationData();
}

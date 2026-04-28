import 'dart:typed_data';
import 'package:flutter/material.dart';

class BusinessRegistrationData {
  final String panNumber;
  final String? panFileName;
  final Uint8List? panBytes;
  final String? profileFileName;
  final Uint8List? profileBytes;

  final String accountNumber;
  final String bankDocType;
  final String? bankDocFileName;
  final Uint8List? bankDocBytes;

  final String addressProofDocType;
  final String? addressProofFileName;
  final Uint8List? addressProofBytes;

  final String addressType; // Standard or Custom label
  final String doorNumber;
  final String streetName;
  final String buildingName;
  final String landmark;
  final String area;
  final String district;
  final String pincode;
  final String state;
  final String country;

  BusinessRegistrationData({
    required this.panNumber,
    this.panFileName,
    this.panBytes,
    this.profileFileName,
    this.profileBytes,
    required this.accountNumber,
    required this.bankDocType,
    this.bankDocFileName,
    this.bankDocBytes,
    required this.addressProofDocType,
    this.addressProofFileName,
    this.addressProofBytes,
    required this.addressType,
    required this.doorNumber,
    required this.streetName,
    required this.buildingName,
    required this.landmark,
    required this.area,
    required this.district,
    required this.pincode,
    required this.state,
    required this.country,
  });
}

class BusinessCreatedDetailsPage extends StatelessWidget {
  final BusinessRegistrationData data;

  const BusinessCreatedDetailsPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFF8B5CF6);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
        title: const Text(
          "Business Upgrade",
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w800),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Success Header
            _buildSuccessHeader(),
            const SizedBox(height: 24),

            // Details Section
            _buildDetailsCard(context, themeColor),
            const SizedBox(height: 32),

            // Navigation Buttons
            _buildBottomButtons(context, themeColor),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle, color: Colors.green, size: 48),
        ),
        const SizedBox(height: 16),
        const Text(
          "Business User Created Successfully",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 8),
        const Text(
          "Your business profile has been created successfully.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(BuildContext context, Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic Info
          _buildDetailSectionTitle("SECTION 1: PAN / PERSONAL / BASIC"),
          _buildSimpleDetail("PAN Number", data.panNumber),
          const SizedBox(height: 12),
          _buildFileRow("PAN Front Photo", data.panFileName, data.panBytes),
          _buildFileRow("Profile Photo", data.profileFileName, data.profileBytes),
          const Divider(height: 48),

          // Bank Info
          _buildDetailSectionTitle("SECTION 2: BANK DETAILS"),
          _buildSimpleDetail("Account Number", _maskAcc(data.accountNumber)),
          _buildSimpleDetail("Document Type", data.bankDocType),
          const SizedBox(height: 12),
          _buildFileRow("Bank Document", data.bankDocFileName, data.bankDocBytes),
          const Divider(height: 48),

          // Address Info
          _buildDetailSectionTitle("SECTION 3: ADDRESS DETAILS"),
          _buildSimpleDetail("Address Proof Type", data.addressProofDocType),
          const SizedBox(height: 12),
          _buildFileRow("Address Proof", data.addressProofFileName, data.addressProofBytes),
          const SizedBox(height: 12),
          _buildSimpleDetail("Address Type", data.addressType),
          _buildSimpleDetail("Door Number", data.doorNumber),
          _buildSimpleDetail("Street Name", data.streetName),
          _buildSimpleDetail("Building Name", data.buildingName),
          _buildSimpleDetail("Landmark", data.landmark),
          _buildSimpleDetail("Area", data.area),
          _buildSimpleDetail("District", data.district),
          _buildSimpleDetail("Pincode", data.pincode),
          _buildSimpleDetail("State", data.state),
          _buildSimpleDetail("Country", data.country),
          const Divider(height: 48),

          // Document Status
          _buildDetailSectionTitle("SECTION 4: DOCUMENT STATUS"),
          _buildStatusRow("PAN", data.panBytes != null),
          _buildStatusRow("Profile", data.profileBytes != null),
          _buildStatusRow("Bank", data.bankDocBytes != null),
          _buildStatusRow("Address", data.addressProofBytes != null),
        ],
      ),
    );
  }

  Widget _buildDetailSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6)),
      ),
    );
  }

  Widget _buildSimpleDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          Text(value.isEmpty ? 'N/A' : value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildFileRow(String label, String? name, Uint8List? bytes) {
    bool isImage = name != null && (name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.jpeg'));
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: bytes == null
                ? const Text("No file uploaded", style: TextStyle(fontSize: 12))
                : Row(
              children: [
                if (isImage)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.memory(bytes, width: 40, height: 40, fit: BoxFit.cover),
                  )
                else
                  const Icon(Icons.picture_as_pdf, color: Colors.red, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name ?? "unnamed_file",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(ok ? Icons.check_circle : Icons.error, color: ok ? Colors.green : Colors.red, size: 16),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context, Color themeColor) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
            style: ElevatedButton.styleFrom(
              backgroundColor: themeColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text("Back to Home", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {},
          child: const Text("View Business Summary", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  String _maskAcc(String v) => v.length > 4 ? '****${v.substring(v.length - 4)}' : v;
}

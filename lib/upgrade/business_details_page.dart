import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'business_user_model.dart';

class BusinessDetailsPage extends StatelessWidget {
  final BusinessUser business;

  const BusinessDetailsPage({super.key, required this.business});

  @override
  Widget build(BuildContext context) {
    const themeColor = Color(0xFFE11D48); // Pink/Red accent

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Details",
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w900, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          children: [
            // Business Header Card
            _buildHeaderCard(themeColor),
            const SizedBox(height: 20),

            // Details Sections
            _buildDetailsCard(themeColor),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: themeColor.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(Icons.business_center_rounded, color: themeColor, size: 30),
          ),
          const SizedBox(height: 16),
          Text(
            business.businessName,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(100)),
                child: const Text("ACTIVE", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 0.5)),
              ),
              const SizedBox(width: 8),
              Text("ID: ${business.id}", style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(Color themeColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection("TAX & IDENTITY"),
          _buildDetailRow("PAN Number", business.panNumber),
          _buildDetailRow("GST Status", business.gstNumber),

          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),

          _buildInfoSection("BANKING"),
          _buildDetailRow("Account", _maskAcc(business.accountNumber)),
          _buildDetailRow("Doc Type", business.bankDocType),
          const SizedBox(height: 12),
          _buildFilePreview(business.bankDocType, business.bankDocFileName, business.bankDocFileBytes),

          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),

          _buildInfoSection("CONTACT"),
          _buildDetailRow("Email", business.email),
          _buildDetailRow("Phone", business.phone),

          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),

          _buildInfoSection("ADDRESS"),
          _buildAddressText("${business.doorNumber}, ${business.streetName}, ${business.area}, ${business.district}, ${business.state}, ${business.country} - ${business.pincode}"),

          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1)),

          _buildInfoSection("DOCUMENTS"),
          const SizedBox(height: 8),
          _buildFilePreview("Profile Photo", business.signatureFileName, business.signatureFileBytes),
          const SizedBox(height: 16),
          _buildFilePreview("PAN Card", business.panFileName, business.panFileBytes),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF8B5CF6), letterSpacing: 1.0),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0F172A)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressText(String addr) {
    return Text(
      addr,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF0F172A), height: 1.5),
    );
  }

  Widget _buildFilePreview(String label, String? name, Uint8List? bytes) {
    bool isImage = name != null && (name.endsWith('.jpg') || name.endsWith('.png') || name.endsWith('.jpeg'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: bytes != null
              ? (isImage ? ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.memory(bytes, fit: BoxFit.cover)) : const Center(child: Icon(Icons.picture_as_pdf_outlined, color: Colors.red, size: 40)))
              : const Center(child: Text("Not Uploaded", style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)))),
        ),
      ],
    );
  }

  String _maskAcc(String v) => v.length > 4 ? '****${v.substring(v.length - 4)}' : v;
}

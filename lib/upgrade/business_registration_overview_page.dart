import 'package:flutter/material.dart';
import 'package:circuit/upgrade/business_user_model.dart';
import 'package:circuit/core/services/user_service.dart';
import 'new_business_register_page.dart';
import '../widgets/common_dashboard_app_bar.dart';
import '../widgets/business_sidebar_menu.dart';
import 'post_job_page.dart';
import 'posted_jobs_page.dart';
import 'applied_list_page.dart';
import 'assign_candidate_page.dart';
import 'select_registration_type_page.dart';

class BusinessRegistrationOverviewPage extends StatefulWidget {
  final BusinessUser business;

  const BusinessRegistrationOverviewPage({super.key, required this.business});

  @override
  State<BusinessRegistrationOverviewPage> createState() => _BusinessRegistrationOverviewPageState();
}

class _BusinessRegistrationOverviewPageState extends State<BusinessRegistrationOverviewPage> {
  String _userFullName = "";
  String _userGender = "Male";
  String _userMainId = "";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  void _onSectionChanged(String newItem) {
    if (_scaffoldKey.currentState?.isDrawerOpen ?? false) {
      _scaffoldKey.currentState?.closeDrawer();
    }

    if (newItem == 'post_job') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => PostJobPage()));
      return;
    } else if (newItem == 'view_posted_jobs') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PostedJobsPage()));
      return;
    } else if (newItem == 'applied_candidates') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AppliedListPage(isBusinessMode: true)));
      return;
    } else if (newItem == 'assign_candidate') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const AssignCandidatePage()));
      return;
    } else if (newItem == 'add_business') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SelectRegistrationTypePage()));
      return;
    } else if (newItem == 'create_store_category' || newItem == 'create_store') {
      // These are handled by NewBusinessRegisterPage which has its own routing logic
      // It's not ideal, but we'll navigate there and tell it to open the right tab if possible
      // For now just pop back or push NewBusinessRegisterPage
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NewBusinessRegisterPage()));
      return;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    final data = await UserService().getUserData();
    if (mounted) {
      setState(() {
        _userFullName = data['name'] ?? widget.business.businessName;
        _userMainId = data['user_main_id'] ?? widget.business.id;
        _userGender = "Male";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CommonDashboardAppBar(automaticallyImplyLeading: true),
      drawer: isMobile
          ? Drawer(
              child: BusinessSidebarMenu(
                activeItem: 'business_overview',
                onSectionChanged: _onSectionChanged,
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            SizedBox(
              width: 250,
              child: BusinessSidebarMenu(
                activeItem: 'business_overview',
                onSectionChanged: _onSectionChanged,
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildActiveBanner(),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 800) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildPersonalAndBankDetails()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildUploadedDocuments()),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      _buildPersonalAndBankDetails(),
                      const SizedBox(height: 24),
                      _buildUploadedDocuments(),
                    ],
                  );
                }
              }
            ),
            const SizedBox(height: 24),
            _buildRegisteredAddressDetails(),
          ],
        ),
      ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.spaceBetween,
      children: [
        SizedBox(
          width: 400, // Provides a good width for the text to wrap appropriately
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Business Overview",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 4),
              const Text(
                "View your business profile details, bank information, and registered address.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, size: 16),
              label: const Text("Back to Portals"),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NewBusinessRegisterPage(existingBusiness: widget.business),
                  ),
                );
              },
              icon: const Icon(Icons.edit, size: 16),
              label: const Text("Edit Details"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildActiveBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business_center, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Active Registration",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Your business user registration is verified and fully active.",
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle, color: Color(0xFF10B981), size: 16),
                SizedBox(width: 6),
                Text(
                  "Active",
                  style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPersonalAndBankDetails() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              const Text("Personal & Bank Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          const Text("Full Name:", style: TextStyle(color: Colors.grey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(_userFullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Gender:", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(_userGender, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("User Main ID:", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(_userMainId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PAN Number:", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      widget.business.panNumber.isEmpty ? "N/A" : widget.business.panNumber,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF2563EB)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Bank Account Number:", style: TextStyle(color: Colors.grey, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      widget.business.accountNumber.isEmpty ? "N/A" : widget.business.accountNumber, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedDocuments() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.file_copy, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              const Text("Uploaded Documents", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          _buildDocRow(
            context, 
            "Profile Photo:", 
            "Open Profile Photo", 
            widget.business.companyLogoFileName != null && widget.business.companyLogoFileName!.isNotEmpty, 
            widget.business.companyLogoFileName,
          ),
          const SizedBox(height: 16),
          _buildDocRow(
            context, 
            "PAN Card Document:", 
            "Open PAN Card Document", 
            widget.business.panFileName != null && widget.business.panFileName!.isNotEmpty, 
            widget.business.panFileName,
          ),
          const SizedBox(height: 16),
          _buildDocRow(
            context, 
            "Bank Proof Document:", 
            "Open Bank Proof", 
            widget.business.bankDocFileName != null && widget.business.bankDocFileName!.isNotEmpty, 
            widget.business.bankDocFileName,
          ),
          const SizedBox(height: 16),
          _buildDocRow(
            context, 
            "Address Proof Document:", 
            "Open Address Proof", 
            widget.business.addressDocFileName != null && widget.business.addressDocFileName!.isNotEmpty, 
            widget.business.addressDocFileName,
          ),
        ],
      ),
    );
  }

  void _showDocumentPreview(BuildContext context, String title, String? imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          width: 500,
          constraints: const BoxConstraints(maxHeight: 600),
          padding: const EdgeInsets.all(0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Document Preview",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE2E8F0)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: imagePath != null && imagePath.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: InteractiveViewer(
                              child: Image.network(
                                imagePath.startsWith('http') ? imagePath : 'https://managelogin.jobes24x7.com/$imagePath',
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) => const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.broken_image, size: 64, color: Colors.grey),
                                      SizedBox(height: 12),
                                      Text("Image Failed to Load", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.image, size: 64, color: Colors.grey),
                                SizedBox(height: 12),
                                Text("Preview Not Available", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text("No document was uploaded.", style: TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocRow(BuildContext context, String label, String btnLabel, bool isUploaded, String? imagePath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: isUploaded ? () => _showDocumentPreview(context, label, imagePath) : null,
            icon: Icon(isUploaded ? Icons.file_open : Icons.close, size: 18),
            label: Text(isUploaded ? btnLabel : "X $btnLabel"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isUploaded ? const Color(0xFF2563EB) : Colors.white,
              foregroundColor: isUploaded ? Colors.white : Colors.grey,
              elevation: 0,
              side: isUploaded ? null : BorderSide(color: Colors.grey.shade300),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisteredAddressDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.grey.shade600, size: 20),
              const SizedBox(width: 8),
              const Text("Registered Address Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF8FAFC)),
                dataRowMinHeight: 60,
                dataRowMaxHeight: double.infinity,
                columns: const [
                  DataColumn(label: Text("ADDRESS TYPE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                  DataColumn(label: Text("PROPERTY & LOCATION DETAILS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                  DataColumn(label: Text("FULL ADDRESS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                  DataColumn(label: Text("STATUS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey))),
                ],
                rows: [
                  DataRow(
                    cells: [
                      const DataCell(Text("Factory", style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Pincode: ${widget.business.pincode}"),
                              Text("District: ${widget.business.district}"),
                            ],
                          ),
                        )
                      ),
                      DataCell(
                        SizedBox(
                          width: 300,
                          child: Text(
                            "${widget.business.doorNumber}, ${widget.business.streetName}, ${widget.business.area}, ${widget.business.state}, ${widget.business.country}",
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        )
                      ),
                      DataCell(
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green),
                          ),
                          child: const Text("Primary", style: TextStyle(color: Colors.green, fontSize: 12)),
                        )
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../user_service.dart';

class VerifiedUserProfilePage extends StatefulWidget {
  const VerifiedUserProfilePage({super.key});

  @override
  State<VerifiedUserProfilePage> createState() => _VerifiedUserProfilePageState();
}

class _VerifiedUserProfilePageState extends State<VerifiedUserProfilePage> {
  bool _isLoading = true;
  Map<String, dynamic>? _verificationData;
  String _userMainId = '';
  String _userName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    _userMainId = prefs.getString('user_main_id') ?? '';
    _userName = prefs.getString('user_name') ?? '';

    if (_userMainId.isNotEmpty) {
      final details = await UserService().getVerificationDetails(_userMainId);
      if (mounted) {
        setState(() {
          _verificationData = details;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _buildImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) return path;
    return 'https://managelogin.jobes24x7.com/api/$path';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        title: const Text(
          'Verified User Profile',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded, size: 16, color: Color(0xFF6366F1)),
            label: const Text('Back to Portal', style: TextStyle(color: Color(0xFF6366F1), fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
          : _verificationData == null
              ? _buildEmptyState()
              : _buildProfile(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: Color(0xFFEDE9FE), shape: BoxShape.circle),
            child: const Icon(Icons.verified_outlined, color: Color(0xFF6366F1), size: 48),
          ),
          const SizedBox(height: 16),
          const Text('No verification data found', style: TextStyle(fontSize: 16, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    final v = _verificationData!;
    final verificationStatus = v['verification_status']?.toString() ?? 'Pending';
    final gender = v['gender']?.toString() ?? 'N/A';
    final panNumber = v['pan_number']?.toString() ?? 'N/A';
    final govIdType = v['government_id_type']?.toString() ?? 'N/A';
    final profilePhotoUrl = _buildImageUrl(v['profile_photo_path']?.toString());
    final panDocUrl = _buildImageUrl(v['pan_document_path']?.toString());
    final govIdDocUrl = _buildImageUrl(v['government_id_document_path']?.toString());

    final addresses = v['addresses'] as List? ?? [];
    final addressProof = v['address_proof'] as Map<String, dynamic>?;

    final isActive = verificationStatus.toLowerCase() == 'active' ||
        verificationStatus.toLowerCase() == 'verified' ||
        v['verified_at'] != null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Status Banner ───
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive
                    ? [const Color(0xFF10B981), const Color(0xFF059669)]
                    : [const Color(0xFF6366F1), const Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.verified_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Active Registration',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Status: $verificationStatus',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ─── Action Buttons ───
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined, size: 16),
                  label: const Text('Edit Details'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Back to Portal'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF64748B),
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ─── Personal Details Card ───
          _buildCard(
            title: 'Personal Details',
            icon: Icons.person_outline,
            child: Column(
              children: [
                _buildDetailRow('Full Name', _userName.isNotEmpty ? _userName : 'N/A'),
                _buildDivider(),
                _buildDetailRow('Gender', gender),
                _buildDivider(),
                _buildDetailRow('User ID', _userMainId),
                _buildDivider(),
                _buildDetailRow('PAN Number', panNumber),
                _buildDivider(),
                _buildDetailRow('Identity ID Type', govIdType),
                if (addresses.isNotEmpty) ...[
                  _buildDivider(),
                  _buildDetailRow('Address Type', addresses.first['address_type']?.toString() ?? 'N/A'),
                  _buildDivider(),
                  _buildDetailRow('Pincode', addresses.first['pincode']?.toString() ?? 'N/A'),
                ],
                if (addressProof != null) ...[
                  _buildDivider(),
                  _buildDetailRow('Address Proof Type', addressProof['proof_type']?.toString() ?? 'N/A'),
                ] else ...[
                  _buildDivider(),
                  _buildDetailRow('Address Proof Type', 'N/A'),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Uploaded Documents Card ───
          _buildCard(
            title: 'Uploaded Documents',
            icon: Icons.folder_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (profilePhotoUrl.isNotEmpty) ...[
                  _buildDocumentRow(
                    label: 'Profile Photo',
                    imageUrl: profilePhotoUrl,
                    buttonLabel: 'Open Profile Photo',
                    buttonIcon: Icons.image_outlined,
                    buttonColor: const Color(0xFF6366F1),
                  ),
                  const SizedBox(height: 12),
                ],
                if (panDocUrl.isNotEmpty) ...[
                  _buildDocumentRow(
                    label: 'PAN Document',
                    imageUrl: panDocUrl,
                    buttonLabel: 'Open PAN Document',
                    buttonIcon: Icons.description_outlined,
                    buttonColor: const Color(0xFF0EA5E9),
                  ),
                  const SizedBox(height: 12),
                ],
                if (govIdDocUrl.isNotEmpty)
                  _buildDocumentRow(
                    label: '$govIdType Document',
                    imageUrl: govIdDocUrl,
                    buttonLabel: 'Open ID Document',
                    buttonIcon: Icons.badge_outlined,
                    buttonColor: const Color(0xFF10B981),
                  ),
                if (profilePhotoUrl.isEmpty && panDocUrl.isEmpty && govIdDocUrl.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No documents uploaded yet', style: TextStyle(color: Color(0xFF94A3B8))),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Verification Status Card ───
          _buildCard(
            title: 'Verification Status',
            icon: Icons.verified_outlined,
            child: Column(
              children: [
                _buildStatusChip(verificationStatus),
                const SizedBox(height: 12),
                if (v['verified_by'] != null)
                  _buildDetailRow('Verified By', v['verified_by'].toString()),
                if (v['verified_at'] != null)
                  _buildDetailRow('Verified At', v['verified_at'].toString()),
                if (v['remarks'] != null)
                  _buildDetailRow('Remarks', v['remarks'].toString()),
                if (verificationStatus.toLowerCase() == 'pending')
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Color(0xFFD97706), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Your verification is under review. You will be notified once it is approved.',
                            style: TextStyle(color: Color(0xFF92400E), fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(color: Color(0xFFEDE9FE), shape: BoxShape.circle),
                  child: Icon(icon, color: const Color(0xFF6366F1), size: 18),
                ),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B))),
              ],
            ),
          ),
          Divider(color: Colors.grey.shade100, height: 1),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Divider(color: Colors.grey.shade100, height: 1);

  Widget _buildDocumentRow({
    required String label,
    required String imageUrl,
    required String buttonLabel,
    required IconData buttonIcon,
    required Color buttonColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            height: 140,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              height: 80,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
              child: const Center(child: Icon(Icons.broken_image_outlined, color: Colors.grey)),
            ),
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Container(
                height: 80,
                decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showImageFullScreen(imageUrl, label),
            icon: Icon(buttonIcon, size: 16),
            label: Text(buttonLabel, style: const TextStyle(fontSize: 13)),
            style: ElevatedButton.styleFrom(
              backgroundColor: buttonColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    Color bg;
    IconData icon;
    switch (status.toLowerCase()) {
      case 'active':
      case 'verified':
        color = const Color(0xFF10B981);
        bg = const Color(0xFFD1FAE5);
        icon = Icons.check_circle_outline;
        break;
      case 'pending':
        color = const Color(0xFFD97706);
        bg = const Color(0xFFFEF3C7);
        icon = Icons.hourglass_top_rounded;
        break;
      case 'rejected':
        color = const Color(0xFFEF4444);
        bg = const Color(0xFFFEE2E2);
        icon = Icons.cancel_outlined;
        break;
      default:
        color = const Color(0xFF64748B);
        bg = const Color(0xFFF1F5F9);
        icon = Icons.info_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  void _showImageFullScreen(String imageUrl, String title) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black87,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Text('Could not load image', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8, right: 8,
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  child: const Icon(Icons.close, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


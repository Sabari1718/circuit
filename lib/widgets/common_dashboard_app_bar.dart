import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../user_service.dart';
import '../profile_page.dart';
import '../login_page.dart';
import '../home_page.dart'; // Import to use DashboardSection enum

class CommonDashboardAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool automaticallyImplyLeading;
  final DashboardSection? selectedSection;
  final Function(DashboardSection)? onSectionChanged;

  const CommonDashboardAppBar({
    super.key,
    this.title,
    this.automaticallyImplyLeading = false,
    this.selectedSection,
    this.onSectionChanged,
  });

  @override
  Size get preferredSize => Size.fromHeight(selectedSection != null ? 120 : 68);

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  void _showProfileMenu(BuildContext context, BuildContext buttonContext, Map<String, String> userData) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay = Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset(button.size.width - 8, button.size.height), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 18,
      color: Colors.white,
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ListenableBuilder(
            listenable: UserService(),
            builder: (context, _) {
              final photoBytes = UserService().profilePhotoBytes;
              return Container(
                width: 290,
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: const Color(0xFFF59E0B),
                          backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                          child: photoBytes == null ? Text(_getInitials(userData['name']!), style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)) : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(userData['name']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF1E293B), fontSize: 14, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text(userData['email']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500)),
                              const SizedBox(height: 4),
                              Text("ID: ${userData['userId']}", style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Current Status", style: TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w700)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: const Color(0xFFE11D48), borderRadius: BorderRadius.circular(8)),
                          child: Text(userData['accountType']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const PopupMenuDivider(height: 1),
        _buildPopupItem(context, value: 'profile', icon: Icons.person_outline_rounded, title: "View Profile", subtitle: "See your public profile"),
        _buildPopupItem(context, value: 'settings', icon: Icons.settings_outlined, title: "Account Settings", subtitle: "Manage your account"),
        _buildPopupItem(context, value: 'photo', icon: Icons.photo_camera_outlined, title: "Change Photo", subtitle: "Upload new profile picture"),
        const PopupMenuDivider(height: 1),
        _buildPopupItem(context, value: 'logout', icon: Icons.logout_rounded, title: "Logout", subtitle: "Sign out of your account", isLogout: true),
      ],
    ).then((selectedValue) {
      if (selectedValue == null) return;
      _handleMenuAction(context, selectedValue);
    });
  }

  PopupMenuItem<String> _buildPopupItem(BuildContext context, {required String value, required IconData icon, required String title, required String subtitle, bool isLogout = false}) {
    final Color iconBg = isLogout ? const Color(0xFFE11D48).withOpacity(0.10) : const Color(0xFFF1F5F9);
    final Color iconColor = isLogout ? const Color(0xFFE11D48) : const Color(0xFF1E293B);
    final Color titleColor = isLogout ? const Color(0xFFE11D48) : const Color(0xFF1E293B);

    return PopupMenuItem<String>(
      value: value,
      height: 64,
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: titleColor, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10.5, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'profile':
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfilePage()));
        break;
      case 'photo':
        await _pickAndChangePhoto(context);
        break;
      case 'logout':
        await UserService().logout(context);
        break;
      default:
        break;
    }
  }

  Future<void> _pickAndChangePhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
      if (image != null) {
        final bytes = await image.readAsBytes();
        await UserService().updateProfilePhoto(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated successfully"), backgroundColor: Color(0xFF10B981), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating photo: $e"), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, String>>(
      future: UserService().getUserData(),
      builder: (context, snapshot) {
        final userData = snapshot.data ?? {
          'name': 'User',
          'email': 'user@example.com',
          'userId': '0000000000',
          'accountType': 'GUEST'
        };

        return AppBar(
          backgroundColor: const Color(0xFF1E293B),
          elevation: 0,
          toolbarHeight: 68,
          automaticallyImplyLeading: automaticallyImplyLeading,
          titleSpacing: automaticallyImplyLeading ? 0 : 16,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), 
                decoration: BoxDecoration(color: const Color(0xFFF59E0B), borderRadius: BorderRadius.circular(10)), 
                child: const Icon(Icons.layers_rounded, color: Colors.white, size: 18)
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title ?? "UserPortal", 
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  softWrap: false,
                ),
              ),
            ],
          ),
          actions: [
            Builder(
              builder: (buttonContext) {
                return InkWell(
                  onTap: () => _showProfileMenu(context, buttonContext, userData),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8, left: 4),
                    child: ListenableBuilder(
                      listenable: UserService(),
                      builder: (context, _) {
                        final photoBytes = UserService().profilePhotoBytes;
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(width: 8),
                                Stack(
                                  children: [
                                    CircleAvatar(
                                      radius: 17,
                                      backgroundColor: const Color(0xFFF59E0B),
                                      backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                                      child: photoBytes == null ? Text(_getInitials(userData['name']!), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)) : null,
                                    ),
                                    Positioned(right: 0, bottom: 0, child: Container(width: 9, height: 9, decoration: BoxDecoration(color: const Color(0xFF10B981), shape: BoxShape.circle, border: Border.all(color: const Color(0xFF1E293B), width: 1.5)))),
                                  ],
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white54, size: 16),
                              ],
                            );
                          }
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ],
          bottom: selectedSection != null ? PreferredSize(
            preferredSize: const Size.fromHeight(52),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabButton(
                    context, 
                    title: "Activities", 
                    icon: Icons.bolt, 
                    isSelected: selectedSection == DashboardSection.activities,
                    onTap: () => onSectionChanged?.call(DashboardSection.activities),
                  ),
                  const SizedBox(width: 12),
                  _buildTabButton(
                    context, 
                    title: "User Privilege", 
                    icon: Icons.shield_outlined, 
                    isSelected: selectedSection == DashboardSection.privilege,
                    onTap: () => onSectionChanged?.call(DashboardSection.privilege),
                  ),
                ],
              ),
            ),
          ) : null,
        );
      },
    );
  }

  Widget _buildTabButton(BuildContext context, {required String title, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF334155) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: Colors.white.withOpacity(0.1), width: 1) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : Colors.white54, size: 16),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

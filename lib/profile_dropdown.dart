import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'user_service.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class ProfileDropdown {
  static String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  static Future<void> _pickAndChangePhoto(BuildContext context) async {
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

  static Future<void> _handleMenuAction(BuildContext context, String action) async {
    switch (action) {
      case 'profile':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const ProfilePage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SettingsPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
        break;
      case 'photo':
        await _pickAndChangePhoto(context);
        break;
      case 'logout':
        await UserService().logout(context);
        break;
    }
  }

  static void show(BuildContext context, BuildContext buttonContext, Map<String, String> userData) {
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
      useRootNavigator: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 20,
      color: Theme.of(context).brightness == Brightness.dark 
          ? const Color(0xFF1E293B).withOpacity(0.95) 
          : Colors.white.withOpacity(0.95),
      constraints: const BoxConstraints(minWidth: 280),
      items: <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          padding: EdgeInsets.zero,
          child: ListenableBuilder(
            listenable: UserService(),
            builder: (context, _) {
              final photoBytes = UserService().profilePhotoBytes;
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  color: Theme.of(context).brightness == Brightness.dark 
                      ? Colors.white.withOpacity(0.05) 
                      : Colors.grey.withOpacity(0.05),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFF59E0B),
                          backgroundImage: photoBytes != null ? MemoryImage(photoBytes) : null,
                          child: photoBytes == null 
                            ? Text(_getInitials(userData['name'] ?? ''), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)) 
                            : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name'] ?? '', 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis, 
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)
                              ),
                              const SizedBox(height: 2),
                              Text(
                                userData['email'] ?? '', 
                                maxLines: 1, 
                                overflow: TextOverflow.ellipsis, 
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "ID: ${(userData['user_main_id'] != null && userData['user_main_id']!.isNotEmpty) ? userData['user_main_id']! : (userData['userId'] ?? '')}", 
                                  style: const TextStyle(color: Color(0xFF10B981), fontSize: 10, fontWeight: FontWeight.bold)
                                ),
                              ),
                            ],
                          ),
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
        _buildPopupItem(context, value: 'photo', icon: Icons.photo_camera_outlined, title: "Change Photo", subtitle: "Update profile picture"),
        const PopupMenuDivider(height: 1),
        _buildPopupItem(context, value: 'logout', icon: Icons.logout_rounded, title: "Logout", subtitle: "Sign out of your account", isLogout: true),
      ],
    ).then((selectedValue) {
      if (selectedValue == null) return;
      _handleMenuAction(context, selectedValue);
    });
  }

  static PopupMenuItem<String> _buildPopupItem(BuildContext context, {required String value, required IconData icon, required String title, required String subtitle, bool isLogout = false}) {
    final Color iconColor = isLogout ? const Color(0xFFE11D48) : Theme.of(context).primaryColor;
    final Color titleColor = isLogout ? const Color(0xFFE11D48) : (Theme.of(context).brightness == Brightness.dark ? Colors.white : const Color(0xFF1E293B));

    return PopupMenuItem<String>(
      value: value,
      height: 64,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10), 
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1), 
              borderRadius: BorderRadius.circular(12)
            ), 
            child: Icon(icon, color: iconColor, size: 22)
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: titleColor, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

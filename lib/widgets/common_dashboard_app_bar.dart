import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../user_service.dart';
import '../profile_page.dart';
import '../login_page.dart';
import '../home_page.dart';
import '../settings_page.dart';
import '../profile_dropdown.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers.dart';

class CommonDashboardAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String? title;
  final bool automaticallyImplyLeading;
  final DashboardSection? selectedSection;
  final Function(DashboardSection)? onSectionChanged;
  final bool isUpgraded;

  const CommonDashboardAppBar({
    super.key,
    this.title,
    this.automaticallyImplyLeading = false,
    this.selectedSection,
    this.onSectionChanged,
    this.isUpgraded = true,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight((selectedSection != null && isUpgraded) ? 120 : 68);

  String _getInitials(String name) {
    if (name.trim().isEmpty) return "U";
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  Future<void> _pickAndChangePhoto(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        await UserService().updateProfilePhoto(bytes);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile photo updated successfully"),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating photo: $e"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showProfileMenu(
    BuildContext context,
    BuildContext buttonContext,
    Map<String, String> userData,
  ) {
    final RenderBox button = buttonContext.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;

    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(
          Offset(button.size.width - 8, button.size.height),
          ancestor: overlay,
        ),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
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
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
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
                          backgroundImage: photoBytes != null
                              ? MemoryImage(photoBytes)
                              : null,
                          child: photoBytes == null
                              ? Text(
                                  _getInitials(userData['name']!),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData['name']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                userData['email']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                ),
                              ),
                              SizedBox(height: 6),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  "ID: ${(userData['user_main_id'] != null && userData['user_main_id']!.isNotEmpty) ? userData['user_main_id']! : (userData['userId'] ?? '')}",
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
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
        _buildPopupItem(
          context,
          value: 'profile',
          icon: Icons.person_outline_rounded,
          title: "View Profile",
          subtitle: "See your public profile",
        ),
        _buildPopupItem(
          context,
          value: 'settings',
          icon: Icons.settings_outlined,
          title: "Account Settings",
          subtitle: "Manage your account",
        ),
        _buildPopupItem(
          context,
          value: 'photo',
          icon: Icons.photo_camera_outlined,
          title: "Change Photo",
          subtitle: "Update profile picture",
        ),
        const PopupMenuDivider(height: 1),
        _buildPopupItem(
          context,
          value: 'logout',
          icon: Icons.logout_rounded,
          title: "Logout",
          subtitle: "Sign out of your account",
          isLogout: true,
        ),
      ],
    ).then((selectedValue) {
      if (selectedValue == null) return;
      _handleMenuAction(context, selectedValue);
    });
  }

  PopupMenuItem<String> _buildPopupItem(
    BuildContext context, {
    required String value,
    required IconData icon,
    required String title,
    required String subtitle,
    bool isLogout = false,
  }) {
    final Color iconColor = isLogout
        ? const Color(0xFFE11D48)
        : Theme.of(context).primaryColor;
    final Color titleColor = isLogout
        ? const Color(0xFFE11D48)
        : (Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : const Color(0xFF1E293B));

    return PopupMenuItem<String>(
      value: value,
      height: 64,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: titleColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                ),
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
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfilePage()),
        );
        break;
      case 'settings':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsPage()),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<Map<String, String>>(
      future: UserService().getUserData(),
      builder: (context, snapshot) {
        final userData =
            snapshot.data ??
            {
              'name': 'User',
              'email': 'user@example.com',
              'userId': '0000000000',
              'accountType': 'GUEST',
            };

        return AppBar(
          backgroundColor: isDark
              ? const Color(0xFF0F172A)
              : Colors.transparent,
          flexibleSpace: isDark
              ? null
              : Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)], // Premium deep blue to vibrant blue
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
          elevation: 0,
          toolbarHeight: 68,
          automaticallyImplyLeading: automaticallyImplyLeading,
          titleSpacing: automaticallyImplyLeading ? 0 : 20,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            title ?? "UserPortal",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
              letterSpacing: 0.5,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            softWrap: false,
          ),
          actions: [
            // Theme Toggle Icon
            Consumer(
              builder: (context, ref, child) {
                return IconButton(
                  onPressed: () {
                    ref.read(themeProviderState).toggleTheme();
                  },
                  icon: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: isDark ? Colors.amber : Colors.white70,
                    size: 24,
                  ),
                  tooltip: 'Toggle Theme',
                );
              },
            ),
            SizedBox(width: 4),
            // Profile Avatar with Dropdown
            Padding(
              padding: EdgeInsets.only(right: 16, left: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Avatar (Non-clickable)
                  ListenableBuilder(
                    listenable: UserService(),
                    builder: (context, _) {
                      final photoBytes = UserService().profilePhotoBytes;
                      return Stack(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: const Color(0xFFF59E0B),
                            backgroundImage: photoBytes != null
                                ? MemoryImage(photoBytes)
                                : null,
                            child: photoBytes == null
                                ? Text(
                                    _getInitials(userData['name']!),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : const Color(0xFF1E40AF),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(width: 4),
                  // Dropdown Icon (Trigger)
                  Builder(
                    builder: (buttonContext) {
                      return GestureDetector(
                        onTap: () => ProfileDropdown.show(
                          context,
                          buttonContext,
                          userData,
                        ),
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.white70,
                          size: 18,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
          bottom: (selectedSection != null && isUpgraded)
              ? PreferredSize(
                  preferredSize: const Size.fromHeight(52),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildTabButton(
                            context,
                            title: "Career Portals",
                            icon: Icons.work_outline_rounded,
                            isSelected:
                                selectedSection == DashboardSection.career,
                            onTap: () =>
                                onSectionChanged?.call(DashboardSection.career),
                          ),
                          SizedBox(width: 12),
                          _buildTabButton(
                            context,
                            title: "User Privilege",
                            icon: Icons.shield_outlined,
                            isSelected:
                                selectedSection == DashboardSection.privilege,
                            onTap: () => onSectionChanged?.call(
                              DashboardSection.privilege,
                            ),
                          ),
                          SizedBox(width: 12),
                          _buildTabButton(
                            context,
                            title: "Features",
                            icon: Icons.bolt,
                            isSelected:
                                selectedSection == DashboardSection.activities,
                            onTap: () => onSectionChanged?.call(
                              DashboardSection.activities,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _buildTabButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? const Color(0xFF334155)
                    : Colors.white.withOpacity(0.2))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: Colors.white.withOpacity(0.15), width: 1)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.white70,
              size: 16,
            ),
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
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

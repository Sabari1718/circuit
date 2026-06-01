import 'package:flutter/material.dart';
import 'bio_overview_page.dart';
import 'grid_card_page.dart';
import 'grid_verification_page.dart';
import 's_tab_auth_page.dart';

class SidebarMenu extends StatefulWidget {
  final String activeItem;
  final Function(String)? onSectionChanged;

  const SidebarMenu({
    super.key,
    required this.activeItem,
    this.onSectionChanged,
  });

  @override
  State<SidebarMenu> createState() => _SidebarMenuState();
}

class _SidebarMenuState extends State<SidebarMenu> with SingleTickerProviderStateMixin {
  static bool _isSecurityExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_isSecurityExpanded) {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleSecurity() {
    setState(() {
      _isSecurityExpanded = !_isSecurityExpanded;
      if (_isSecurityExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  void _navigateTo(BuildContext context, String item) {
    final isMobile = MediaQuery.of(context).size.width < 768;

    if (isMobile) {
      Widget targetPage;
      if (item == 's_tab') {
        targetPage = const STabAuthPage();
      } else if (item == 'bio_overview' || item == 'authentication' || item == 'verify') {
        targetPage = BioOverviewPage(initialSection: item, showMenuOnlyOnMobile: false);
      } else if (item == 'grid_card') {
        targetPage = const GridCardPage();
      } else if (item == 'grid_verification') {
        targetPage = const GridVerificationPage();
      } else {
        return;
      }

      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => targetPage,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
      return;
    }

    if (widget.activeItem == item) return;

    Widget targetPage;
    if (item == 'bio_overview' || item == 'authentication' || item == 's_tab' || item == 'verify') {
      if (widget.activeItem == 'bio_overview' || widget.activeItem == 'authentication' || widget.activeItem == 's_tab' || widget.activeItem == 'verify') {
        if (widget.onSectionChanged != null) {
          widget.onSectionChanged!(item);
        }
        return;
      }
      targetPage = BioOverviewPage(initialSection: item);
    } else if (item == 'grid_card') {
      targetPage = const GridCardPage();
    } else if (item == 'grid_verification') {
      targetPage = const GridVerificationPage();
    } else {
      return;
    }

    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => targetPage,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = const Color(0xFF2563EB);
    final isMobile = MediaQuery.of(context).size.width < 768;

    return Container(
      width: isMobile ? double.infinity : 250,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMenuItem(
            icon: Icons.badge_outlined,
            title: "Bio Overview",
            isActive: widget.activeItem == 'bio_overview',
            onTap: () => _navigateTo(context, 'bio_overview'),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.shield_outlined,
            title: "Authentication",
            isActive: widget.activeItem == 'authentication',
            onTap: () => _navigateTo(context, 'authentication'),
          ),
          const SizedBox(height: 12),
          _buildExpandableSecurityHeader(primaryColor),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Padding(
              padding: const EdgeInsets.only(left: 12, top: 4, bottom: 4),
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                  ),
                ),
                padding: const EdgeInsets.only(left: 16),
                child: Column(
                  children: [
                    _buildSubMenuItem(
                      icon: Icons.settings_outlined,
                      title: "S-Tab",
                      isActive: widget.activeItem == 's_tab',
                      onTap: () => _navigateTo(context, 's_tab'),
                    ),
                    const SizedBox(height: 8),
                    _buildSubMenuItem(
                      icon: Icons.check_circle_outline_rounded,
                      title: "Verify",
                      isActive: widget.activeItem == 'verify',
                      onTap: () => _navigateTo(context, 'verify'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildMenuItem(
            icon: Icons.grid_view_rounded,
            title: "Grid Card",
            isActive: widget.activeItem == 'grid_card',
            onTap: () => _navigateTo(context, 'grid_card'),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => _navigateTo(context, 'grid_verification'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Grid Verification",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final primaryColor = const Color(0xFF2563EB);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? primaryColor.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 22,
            ),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: const Color(0xFF1E293B),
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSecurityHeader(Color primaryColor) {
    final isAnySubItemActive = widget.activeItem == 's_tab' || widget.activeItem == 'verify';
    return InkWell(
      onTap: _toggleSecurity,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isAnySubItemActive ? primaryColor.withOpacity(0.04) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.admin_panel_settings_outlined,
              color: primaryColor,
              size: 22,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                "Security",
                style: TextStyle(
                  color: const Color(0xFF1E293B),
                  fontWeight: isAnySubItemActive ? FontWeight.bold : FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
            RotationTransition(
              turns: Tween<double>(begin: 0.0, end: 0.5).animate(
                CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.easeInOut,
                ),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF94A3B8),
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubMenuItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final Color itemColor = isActive ? const Color(0xFF2563EB) : const Color(0xFF64748B);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF2563EB).withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: itemColor,
              size: 18,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: itemColor,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

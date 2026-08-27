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
      width: isMobile ? double.infinity : 280,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: isMobile
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 20,
                  offset: const Offset(4, 0),
                )
              ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 8, bottom: 16),
            child: Text(
              "MENU",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Color(0xFF94A3B8),
                letterSpacing: 1.2,
              ),
            ),
          ),
          _buildMenuItem(
            icon: Icons.badge_rounded,
            title: "Bio Overview",
            isActive: widget.activeItem == 'bio_overview',
            onTap: () => _navigateTo(context, 'bio_overview'),
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.shield_rounded,
            title: "Authentication",
            isActive: widget.activeItem == 'authentication',
            onTap: () => _navigateTo(context, 'authentication'),
          ),
          const SizedBox(height: 8),
          _buildExpandableSecurityHeader(primaryColor),
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(left: 22, top: 8, bottom: 8),
              decoration: const BoxDecoration(
                border: Border(
                  left: BorderSide(color: Color(0xFFE2E8F0), width: 2),
                ),
              ),
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                children: [
                  _buildSubMenuItem(
                    icon: Icons.settings_rounded,
                    title: "S-Tab Settings",
                    isActive: widget.activeItem == 's_tab',
                    onTap: () => _navigateTo(context, 's_tab'),
                  ),
                  const SizedBox(height: 4),
                  _buildSubMenuItem(
                    icon: Icons.verified_rounded,
                    title: "Verification Status",
                    isActive: widget.activeItem == 'verify',
                    onTap: () => _navigateTo(context, 'verify'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildMenuItem(
            icon: Icons.grid_view_rounded,
            title: "Grid Card",
            isActive: widget.activeItem == 'grid_card',
            onTap: () => _navigateTo(context, 'grid_card'),
          ),
          const Spacer(),
          _buildPremiumButton(context, primaryColor),
        ],
      ),
    );
  }

  Widget _buildPremiumButton(BuildContext context, Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateTo(context, 'grid_verification'),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withOpacity(0.2),
          highlightColor: Colors.transparent,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.verified_user_rounded, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  "Grid Verification",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final activeColor = const Color(0xFF2563EB);
    final inactiveColor = const Color(0xFF64748B);
    final activeBgColor = const Color(0xFFEFF6FF);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isActive ? activeBgColor : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActive ? activeColor.withOpacity(0.15) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: activeColor.withOpacity(0.1),
          highlightColor: activeColor.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: isActive ? activeColor : inactiveColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isActive ? const Color(0xFF1E3A8A) : const Color(0xFF334155),
                      fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ),
                if (isActive)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withOpacity(0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSecurityHeader(Color primaryColor) {
    final isAnySubItemActive = widget.activeItem == 's_tab' || widget.activeItem == 'verify';
    final inactiveColor = const Color(0xFF64748B);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: isAnySubItemActive ? const Color(0xFFEFF6FF) : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isAnySubItemActive ? primaryColor.withOpacity(0.15) : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _toggleSecurity,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.admin_panel_settings_rounded,
                  color: isAnySubItemActive ? primaryColor : inactiveColor,
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Security",
                    style: TextStyle(
                      color: isAnySubItemActive ? const Color(0xFF1E3A8A) : const Color(0xFF334155),
                      fontWeight: isAnySubItemActive ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
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
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isAnySubItemActive ? primaryColor : inactiveColor,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),
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
    final activeColor = const Color(0xFF2563EB);
    final inactiveColor = const Color(0xFF64748B);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: activeColor.withOpacity(0.1),
        highlightColor: activeColor.withOpacity(0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              Icon(
                icon,
                color: isActive ? activeColor : inactiveColor,
                size: 20,
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  color: isActive ? activeColor : inactiveColor,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

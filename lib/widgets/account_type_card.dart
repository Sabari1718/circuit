import 'package:flutter/material.dart';

class AccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String icon; // Using String for Emoji or Icon Data
  final Color color;
  final bool isCompleted;
  
  // New properties for Web UI matching
  final String? planName;
  final String? accessLevel;
  
  final Widget? customPrimaryWidget; 
  final Widget? customDescriptionWidget; 
  final bool hidePrimaryButton; 
  final String? primaryButtonText; 
  final Widget? topRightAction; 
  final VoidCallback onPrimaryTap;
  final VoidCallback onReadMoreTap;

  const AccountTypeCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    this.isCompleted = false,
    this.planName,
    this.accessLevel,
    this.customPrimaryWidget,
    this.customDescriptionWidget,
    this.hidePrimaryButton = false,
    this.primaryButtonText,
    this.topRightAction,
    required this.onPrimaryTap,
    required this.onReadMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xFF10B981);
    
    // Status color
    final statusColor = isCompleted ? greenColor : Colors.grey.shade400;
    final statusBgColor = isCompleted ? greenColor.withOpacity(0.1) : Colors.orange.withOpacity(0.1);
    final statusTextColor = isCompleted ? greenColor : Colors.orange;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Star icon and Active/Inactive Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  Icons.star_outline_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isCompleted ? "Active" : "Inactive",
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            
            // Center Content
            Column(
              children: [
                Container(
                  width: 44, // Slightly smaller icon container
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15), // Softer background
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      icon,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "$title $subtitle".toUpperCase(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                    color: Color(0xFF1E293B),
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
            
            // Table removed as requested to keep UI clean and uncluttered

            // Bottom Buttons (Stacked vertically, larger size for premium mass look)
            Column(
              children: [
                if (!hidePrimaryButton) ...[
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: customPrimaryWidget ?? ElevatedButton(
                      onPressed: onPrimaryTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted ? const Color(0xFF10B981) : const Color(0xFF3B82F6),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!isCompleted) ...[
                            const Icon(Icons.stars, size: 16),
                            const SizedBox(width: 6),
                          ],
                          Text(
                            primaryButtonText ?? (isCompleted ? "View" : "Upgrade"),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: OutlinedButton(
                    onPressed: onReadMoreTap,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      foregroundColor: const Color(0xFF64748B),
                    ),
                    child: const Text(
                      "View Details",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, {bool isStatus = false, Color? statusColor}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 8,
            fontWeight: FontWeight.w700,
            color: Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: isStatus ? (statusColor ?? const Color(0xFF10B981)) : const Color(0xFF334155),
          ),
        ),
      ],
    );
  }
}

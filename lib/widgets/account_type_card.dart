import 'package:flutter/material.dart';

class AccountTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String description;
  final String icon; // Using String for Emoji or Icon Data
  final Color color;
  final bool isCompleted;
  final Widget? customPrimaryWidget; 
  final Widget? customDescriptionWidget; // New property to replace description box
  final bool hidePrimaryButton; // New property to hide primary button area
  final String? primaryButtonText; // New property for custom button text
  final Widget? topRightAction; // New property for top right action (e.g., expand arrow)
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
    // Exact colors from requirements
    const Color purpleColor = Color(0xFF7C3AED);
    const Color greenColor = Color(0xFF10B981);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCompleted ? greenColor : const Color(0xFFE2E8F0),
          width: isCompleted ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Center Icon
                Column(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title Bold Uppercase
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.5,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Subtitle
                    Text(
                      subtitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                // Description Box or Custom Widget
                if (customDescriptionWidget != null)
                  customDescriptionWidget!
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                // Bottom Buttons
                Row(
                  children: [
                    if (!hidePrimaryButton) ...[
                      Expanded(
                        child: customPrimaryWidget ?? SizedBox(
                          height: 34,
                          child: ElevatedButton(
                            onPressed: onPrimaryTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCompleted ? greenColor : purpleColor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              primaryButtonText ?? (isCompleted ? "VIEW" : "UPGRADE"),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 9, // Slightly smaller to fit longer text
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: SizedBox(
                        height: 34,
                        child: OutlinedButton(
                          onPressed: onReadMoreTap,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            "READ MORE",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isCompleted)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: greenColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          if (topRightAction != null)
            Positioned(
              top: 10,
              right: 10,
              child: topRightAction!,
            ),
        ],
      ),
    );
  }
}

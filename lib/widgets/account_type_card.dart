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
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isCompleted ? greenColor.withOpacity(0.5) : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isCompleted ? greenColor : color).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 14.0),
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
                        gradient: LinearGradient(
                          colors: [
                            color.withOpacity(0.2),
                            color.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          icon,
                          style: const TextStyle(fontSize: 26),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Title Bold Uppercase
                    Text(
                      title.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        letterSpacing: 0.8,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Subtitle
                    Text(
                      subtitle.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        letterSpacing: 1.2,
                        color: color.withOpacity(0.8),
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
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Text(
                      description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                        height: 1.4,
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
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: isCompleted
                                  ? const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    )
                                  : LinearGradient(
                                      colors: [color, color.withOpacity(0.8)],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                              boxShadow: [
                                BoxShadow(
                                  color: (isCompleted ? greenColor : color).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: onPrimaryTap,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.zero,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                primaryButtonText ?? "UPGRADE",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
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
                            side: BorderSide(color: Colors.grey.shade300, width: 1.5),
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            foregroundColor: const Color(0xFF475569),
                          ),
                          child: const Text(
                            "Details",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
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
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: greenColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: greenColor.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/models/installed_app.dart';
import '../../../core/widgets/refocus_components.dart';

class AppListTile extends StatelessWidget {
  final InstalledApp app;
  final ValueChanged<bool?> onToggle;

  const AppListTile({
    super.key,
    required this.app,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final iconBytes = app.iconBytes;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: RefocusCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        backgroundColor: app.isSelected
            ? AppColors.primary.withOpacity(0.08)
            : AppColors.surface,
        border: Border.all(
          color: app.isSelected
              ? AppColors.primary.withOpacity(0.4)
              : AppColors.border,
          width: app.isSelected ? 1.5 : 1,
        ),
        onTap: () => onToggle(!app.isSelected),
        child: Row(
          children: [
            // App Icon
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: iconBytes != null
                  ? Image.memory(
                      iconBytes,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
                    )
                  : _buildFallbackIcon(),
            ),
            const SizedBox(width: 14),
            // App Name & Package
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    app.appName,
                    style: GoogleFonts.inter(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: app.isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    app.packageName,
                    style: GoogleFonts.inter(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Glowing Purple Switch / Indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: app.isSelected ? AppColors.primary : AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(
                  color: app.isSelected ? AppColors.primary : AppColors.borderLight,
                  width: 1.5,
                ),
                boxShadow: app.isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: app.isSelected ? Colors.white : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceHover,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.android_rounded,
        color: AppColors.textSecondary,
        size: 24,
      ),
    );
  }
}

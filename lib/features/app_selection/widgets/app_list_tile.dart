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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: RefocusCard(
        tonalElevation: app.isSelected ? 3 : 1,
        borderRadius: AppRadius.large,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        backgroundColor: app.isSelected
            ? const Color(0xFF15221F)
            : AppColors.surfaceContainer,
        border: Border.all(
          color: app.isSelected
              ? AppColors.neonMint
              : AppColors.border,
          width: 2.0,
        ),
        onTap: () => onToggle(!app.isSelected),
        child: Row(
          children: [
            // App Icon Container (Neo-Brutalist Square Box)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: app.isSelected
                      ? AppColors.neonMint
                      : AppColors.border,
                  width: 2.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF000000),
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: iconBytes != null && iconBytes.isNotEmpty
                    ? Image.memory(
                        iconBytes,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (context, error, stackTrace) {
                          debugPrint('Image.memory error for ${app.packageName}: $error');
                          return _buildFallbackIcon();
                        },
                      )
                    : _buildFallbackIcon(),
              ),
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
                      fontWeight: app.isSelected ? FontWeight.w800 : FontWeight.w600,
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
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Neo-Brutalist Selection Checkbox
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: app.isSelected ? AppColors.neonMint : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: const Color(0xFF000000),
                  width: 2.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xFF000000),
                    offset: Offset(2, 2),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: app.isSelected ? const Color(0xFF090A0F) : Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    final initial = app.appName.trim().isNotEmpty
        ? app.appName.trim().characters.first.toUpperCase()
        : '';

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(2),
      ),
      child: Center(
        child: initial.isNotEmpty
            ? Text(
                initial,
                style: GoogleFonts.outfit(
                  color: AppColors.neonMint,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              )
            : const Icon(
                Icons.android_rounded,
                color: AppColors.neonMint,
                size: 22,
              ),
      ),
    );
  }
}


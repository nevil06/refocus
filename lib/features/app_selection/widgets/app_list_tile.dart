import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/models/installed_app.dart';

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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: app.isSelected ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: app.isSelected ? AppColors.primary.withOpacity(0.35) : AppColors.border,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: iconBytes != null
              ? Image.memory(
                  iconBytes,
                  width: 42,
                  height: 42,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _buildFallbackIcon(),
                )
              : _buildFallbackIcon(),
        ),
        title: Text(
          app.appName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: app.isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          app.packageName,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Checkbox(
          value: app.isSelected,
          onChanged: onToggle,
          activeColor: AppColors.primary,
          checkColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        onTap: () => onToggle(!app.isSelected),
      ),
    );
  }

  Widget _buildFallbackIcon() {
    return Container(
      width: 42,
      height: 42,
      color: AppColors.surfaceHover,
      child: const Icon(Icons.android_rounded, color: AppColors.textSecondary, size: 24),
    );
  }
}

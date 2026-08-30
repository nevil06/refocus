import 'package:flutter/material.dart';
import '../../../app/theme.dart';
import '../../../core/constants/durations.dart';

class DurationPicker extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onDurationSelected;

  const DurationPicker({
    super.key,
    required this.selectedMinutes,
    required this.onDurationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FOCUS DURATION',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.cyan,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            ...presetDurations.map((preset) {
              final isSelected = selectedMinutes == preset.minutes;
              return InkWell(
                onTap: () => onDurationSelected(preset.minutes),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.border,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    preset.label,
                    style: TextStyle(
                      color: isSelected ? Colors.black : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }),
            InkWell(
              onTap: () => _showCustomDurationDialog(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: !presetDurations.any((p) => p.minutes == selectedMinutes)
                      ? AppColors.primary
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: !presetDurations.any((p) => p.minutes == selectedMinutes)
                        ? AppColors.primary
                        : AppColors.border,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  !presetDurations.any((p) => p.minutes == selectedMinutes)
                      ? '${selectedMinutes}m (Custom)'
                      : 'Custom...',
                  style: TextStyle(
                    color: !presetDurations.any((p) => p.minutes == selectedMinutes)
                        ? Colors.black
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showCustomDurationDialog(BuildContext context) {
    final controller = TextEditingController(text: selectedMinutes.toString());
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Custom Duration'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Minutes',
            suffixText: 'min',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              final mins = int.tryParse(controller.text);
              if (mins != null && mins > 0 && mins <= 720) {
                onDurationSelected(mins);
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Set'),
          ),
        ],
      ),
    );
  }
}

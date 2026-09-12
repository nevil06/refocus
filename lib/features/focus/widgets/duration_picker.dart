import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/refocus_components.dart';

class DurationOption {
  final int minutes;
  final String label;

  const DurationOption({required this.minutes, required this.label});
}

const List<DurationOption> standardDurations = [
  DurationOption(minutes: 15, label: '15m'),
  DurationOption(minutes: 25, label: '25m'),
  DurationOption(minutes: 45, label: '45m'),
  DurationOption(minutes: 60, label: '1h'),
  DurationOption(minutes: 90, label: '1h 30m'),
  DurationOption(minutes: 120, label: '2h'),
];

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
    final isCustomSelected = !standardDurations.any((d) => d.minutes == selectedMinutes);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RefocusSectionHeader(
          title: 'Duration',
          accentColor: AppColors.secondary,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...standardDurations.map((preset) {
              final isSelected = selectedMinutes == preset.minutes;
              return RefocusChip(
                label: preset.label,
                isSelected: isSelected,
                icon: Icons.timer_outlined,
                borderRadius: AppRadius.full,
                onTap: () => onDurationSelected(preset.minutes),
              );
            }),
            RefocusChip(
              label: isCustomSelected ? '${selectedMinutes}m (Custom)' : 'Custom',
              isSelected: isCustomSelected,
              icon: Icons.tune_rounded,
              borderRadius: AppRadius.full,
              onTap: () => _showCustomDurationDialog(context),
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
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.extraLargeRadius,
          side: const BorderSide(color: AppColors.border),
        ),
        title: Row(
          children: [
            const Icon(Icons.timer_outlined, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text(
              'Custom Duration',
              style: GoogleFonts.outfit(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Duration in minutes',
            suffixText: 'min',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          RefocusButton(
            text: 'Apply',
            isFullWidth: false,
            height: 42,
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0 && val <= 720) {
                onDurationSelected(val);
              }
              Navigator.of(dialogContext).pop();
            },
          ),
        ],
      ),
    );
  }
}

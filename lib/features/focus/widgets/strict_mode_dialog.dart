import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/refocus_components.dart';

class StrictModeStopDialog extends StatefulWidget {
  final bool isStrictMode;
  final VoidCallback onConfirmStop;

  const StrictModeStopDialog({
    super.key,
    required this.isStrictMode,
    required this.onConfirmStop,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isStrictMode,
    required VoidCallback onConfirmStop,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StrictModeStopDialog(
        isStrictMode: isStrictMode,
        onConfirmStop: onConfirmStop,
      ),
    );
  }

  @override
  State<StrictModeStopDialog> createState() => _StrictModeStopDialogState();
}

class _StrictModeStopDialogState extends State<StrictModeStopDialog> {
  int _countdown = 5;
  Timer? _timer;
  final TextEditingController _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isStrictMode) {
      _timer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (_countdown > 0) {
          if (mounted) setState(() => _countdown--);
        } else {
          t.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isStrictMode) {
      return AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          'End Focus Session?',
          style: GoogleFonts.outfit(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          'Your session will be marked as interrupted and shielded apps will be unlocked.',
          style: GoogleFonts.inter(
            color: AppColors.textSecondary,
            fontSize: 13,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Stay Focused', style: TextStyle(color: AppColors.textSecondary)),
          ),
          RefocusButton(
            text: 'Stop Session',
            variant: RefocusButtonVariant.danger,
            isFullWidth: false,
            height: 42,
            onPressed: () {
              Navigator.pop(context);
              widget.onConfirmStop();
            },
          ),
        ],
      );
    }

    final isWordConfirmed = _confirmController.text.trim().toUpperCase() == 'STOP';
    final canStop = _countdown == 0 && isWordConfirmed;

    return AlertDialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.lock_clock_rounded, color: AppColors.amber, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Friction Mode Active',
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'You enabled Friction Mode to protect your deep focus. Early cancellation requires confirmation.',
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Type "STOP" to confirm:',
            style: GoogleFonts.inter(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmController,
            autofocus: true,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Type STOP',
            ),
          ),
          if (_countdown > 0) ...[
            const SizedBox(height: 12),
            Text(
              'Please pause for $_countdown seconds to reconsider...',
              style: GoogleFonts.inter(
                color: AppColors.amber,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Stay Focused', style: TextStyle(color: AppColors.textSecondary)),
        ),
        RefocusButton(
          text: 'Give Up & Stop',
          variant: RefocusButtonVariant.danger,
          isFullWidth: false,
          height: 42,
          onPressed: canStop
              ? () {
                  Navigator.pop(context);
                  widget.onConfirmStop();
                }
              : null,
        ),
      ],
    );
  }
}

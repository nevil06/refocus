import 'dart:async';
import 'package:flutter/material.dart';
import '../../../app/theme.dart';

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
          setState(() => _countdown--);
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
        backgroundColor: AppColors.surface,
        title: const Text('Stop Focus Session?'),
        content: const Text(
          'Your session will be marked as interrupted and blocked apps will be unlocked.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Continue Focus'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onConfirmStop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Stop Session'),
          ),
        ],
      );
    }

    final isWordConfirmed = _confirmController.text.trim().toUpperCase() == 'STOP';
    final canStop = _countdown == 0 && isWordConfirmed;

    return AlertDialog(
      backgroundColor: AppColors.surface,
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: AppColors.amber, size: 28),
          const SizedBox(width: 10),
          const Text('Strict Mode Active'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'You enabled Strict Mode to protect your focus. Stopping will mark this session interrupted.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 16),
          const Text(
            'Type "STOP" below to confirm:',
            style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold, fontSize: 13),
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
              'Please wait $_countdown seconds to reconsider...',
              style: const TextStyle(color: AppColors.amber, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Stay in Focus'),
        ),
        ElevatedButton(
          onPressed: canStop
              ? () {
                  Navigator.pop(context);
                  widget.onConfirmStop();
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.red,
            disabledBackgroundColor: AppColors.red.withOpacity(0.3),
          ),
          child: const Text('Give Up & Stop'),
        ),
      ],
    );
  }
}

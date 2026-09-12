import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../app/theme.dart';

// =============================================================================
// REFOCUS BUTTON (Material 3 Stadium Shape)
// =============================================================================
enum RefocusButtonVariant { primary, secondary, outlined, danger, ghost }

class RefocusButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final RefocusButtonVariant variant;
  final bool isFullWidth;
  final bool isLoading;
  final double height;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;

  const RefocusButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.leading,
    this.trailing,
    this.variant = RefocusButtonVariant.primary,
    this.isFullWidth = true,
    this.isLoading = false,
    this.height = 54.0,
    this.padding,
    this.borderRadius,
  });

  @override
  State<RefocusButton> createState() => _RefocusButtonState();
}

class _RefocusButtonState extends State<RefocusButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onPressed == null || widget.isLoading;
    final effectiveRadius = widget.borderRadius ?? AppRadius.large;

    Color bg;
    Color fg;
    Border? border;
    List<BoxShadow>? shadows;

    final shadowOffset = _isPressed ? const Offset(1, 1) : const Offset(4, 4);

    switch (widget.variant) {
      case RefocusButtonVariant.primary:
        bg = AppColors.neonMint;
        fg = const Color(0xFF090A0F);
        border = Border.all(color: const Color(0xFF000000), width: 2.5);
        shadows = isDisabled
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF000000),
                  offset: shadowOffset,
                  blurRadius: 0,
                )
              ];
        break;
      case RefocusButtonVariant.secondary:
        bg = AppColors.surfaceContainerHigh;
        fg = AppColors.textPrimary;
        border = Border.all(color: AppColors.border, width: 2.0);
        shadows = isDisabled
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF000000),
                  offset: shadowOffset,
                  blurRadius: 0,
                )
              ];
        break;
      case RefocusButtonVariant.outlined:
        bg = AppColors.surfaceContainer;
        fg = AppColors.textPrimary;
        border = Border.all(color: AppColors.border, width: 2.0);
        shadows = isDisabled
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF000000),
                  offset: shadowOffset,
                  blurRadius: 0,
                )
              ];
        break;
      case RefocusButtonVariant.danger:
        bg = AppColors.coralRed;
        fg = Colors.white;
        border = Border.all(color: const Color(0xFF000000), width: 2.5);
        shadows = isDisabled
            ? null
            : [
                BoxShadow(
                  color: const Color(0xFF000000),
                  offset: shadowOffset,
                  blurRadius: 0,
                )
              ];
        break;
      case RefocusButtonVariant.ghost:
        bg = Colors.transparent;
        fg = AppColors.textSecondary;
        border = null;
        shadows = null;
        break;
    }

    Widget content = Row(
      mainAxisSize: widget.isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          ),
          const SizedBox(width: 10),
        ] else if (widget.leading != null) ...[
          widget.leading!,
          const SizedBox(width: 8),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: fg),
          const SizedBox(width: 8),
        ],
        Text(
          widget.text,
          style: GoogleFonts.inter(
            color: fg,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        if (widget.trailing != null && !widget.isLoading) ...[
          const SizedBox(width: 8),
          widget.trailing!,
        ],
      ],
    );

    return GestureDetector(
      onTapDown: (_) {
        if (!isDisabled) setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        if (!isDisabled) setState(() => _isPressed = false);
      },
      onTapCancel: () {
        if (!isDisabled) setState(() => _isPressed = false);
      },
      child: Transform.translate(
        offset: _isPressed && !isDisabled ? const Offset(3, 3) : Offset.zero,
        child: Container(
          height: widget.height,
          width: widget.isFullWidth ? double.infinity : null,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(effectiveRadius),
            border: border,
            boxShadow: shadows,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : widget.onPressed,
              borderRadius: BorderRadius.circular(effectiveRadius),
              splashColor: AppColors.neonMint.withOpacity(0.15),
              highlightColor: Colors.transparent,
              child: Padding(
                padding: widget.padding ??
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REFOCUS CARD (Neo-Brutalism Flat Block, Solid 2px Border & Hard Offset Shadow)
// =============================================================================
class RefocusCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Gradient? gradient;
  final Border? border;
  final double borderRadius;
  final bool hasGlow;
  final int tonalElevation; // 0=lowest, 1=low, 2=surface, 3=high, 4=highest

  const RefocusCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.backgroundColor,
    this.gradient,
    this.border,
    this.borderRadius = AppRadius.large,
    this.hasGlow = false,
    this.tonalElevation = 2,
  });

  Color _resolveSurfaceColor() {
    if (backgroundColor != null) return backgroundColor!;
    switch (tonalElevation) {
      case 0:
        return AppColors.surfaceContainerLowest;
      case 1:
        return AppColors.surfaceContainerLow;
      case 2:
        return AppColors.surfaceContainer;
      case 3:
        return AppColors.surfaceContainerHigh;
      case 4:
      default:
        return AppColors.surfaceContainerHighest;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaceBg = _resolveSurfaceColor();
    final effectiveBorder = border ??
        Border.all(
          color: hasGlow
              ? AppColors.neonMint
              : AppColors.border,
          width: 2.0,
        );

    final cardContent = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: surfaceBg,
        borderRadius: BorderRadius.circular(borderRadius),
        border: effectiveBorder,
        boxShadow: [
          hasGlow
              ? const BoxShadow(
                  color: AppColors.neonMint,
                  offset: Offset(4, 4),
                  blurRadius: 0,
                )
              : AppShadows.cardShadow,
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return Container(
        margin: margin,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            splashColor: AppColors.neonMint.withOpacity(0.12),
            child: cardContent,
          ),
        ),
      );
    }

    if (margin != null) {
      return Padding(padding: margin!, child: cardContent);
    }
    return cardContent;
  }
}

// =============================================================================
// REFOCUS ICON BUTTON (Sharp Neo-Brutalist Shape, 2px Border & Hard Shadow)
// =============================================================================
class RefocusIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;
  final Color? backgroundColor;
  final double size;
  final double iconSize;
  final String? tooltip;

  const RefocusIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor,
    this.backgroundColor,
    this.size = 44.0,
    this.iconSize = 20.0,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    Widget btn = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(AppRadius.large),
          splashColor: AppColors.neonMint.withOpacity(0.15),
          child: Center(
            child: Icon(
              icon,
              size: iconSize,
              color: iconColor ?? AppColors.textPrimary,
            ),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: btn);
    }
    return btn;
  }
}

// =============================================================================
// REFOCUS CHIP (Neo-Brutalism Sharp 4px Corner, 2px Border & Hard Shadow)
// =============================================================================
class RefocusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final IconData? icon;
  final Widget? leading;
  final Color? activeColor;
  final double borderRadius;

  const RefocusChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.icon,
    this.leading,
    this.activeColor,
    this.borderRadius = AppRadius.large,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.neonMint;

    return Container(
      decoration: BoxDecoration(
        color: isSelected ? color : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: isSelected ? const Color(0xFF000000) : AppColors.border,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000),
            offset: isSelected ? const Offset(3, 3) : const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 6),
                ] else if (icon != null) ...[
                  Icon(
                    icon,
                    size: 15,
                    color: isSelected ? const Color(0xFF090A0F) : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                ],
                Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? const Color(0xFF090A0F) : AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// REFOCUS SEGMENTED PICKER (Neo-Brutalism Sharp Segmented Button)
// =============================================================================
class RefocusSegmentItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? activeColor;

  const RefocusSegmentItem({
    required this.value,
    required this.label,
    this.icon,
    this.activeColor,
  });
}

class RefocusSegmentedPicker<T> extends StatelessWidget {
  final List<RefocusSegmentItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final EdgeInsetsGeometry? padding;

  const RefocusSegmentedPicker({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border, width: 2.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(3, 3),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        children: items.map((item) {
          final isSelected = item.value == selectedValue;
          final activeColor = item.activeColor ?? AppColors.neonMint;

          return Expanded(
            child: GestureDetector(
              onTap: () => onValueChanged(item.value),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.small),
                  border: isSelected
                      ? Border.all(color: const Color(0xFF000000), width: 2.0)
                      : null,
                  boxShadow: isSelected
                      ? const [
                          BoxShadow(
                            color: Color(0xFF000000),
                            offset: Offset(2, 2),
                            blurRadius: 0,
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (item.icon != null) ...[
                      Icon(
                        item.icon,
                        size: 15,
                        color: isSelected ? const Color(0xFF090A0F) : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      item.label,
                      style: GoogleFonts.inter(
                        color: isSelected ? const Color(0xFF090A0F) : AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// =============================================================================
// REFOCUS STAT CARD (Neo-Brutalism Chunky Stat Card, 2px Border & Hard Shadow)
// =============================================================================
class RefocusStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;
  final int tonalElevation;

  const RefocusStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    this.onTap,
    this.tonalElevation = 3,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = tonalElevation == 3
        ? AppColors.surfaceContainerHigh
        : AppColors.surfaceContainer;

    Widget card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.border, width: 2.0),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(AppRadius.small),
              border: Border.all(color: const Color(0xFF000000), width: 1.5),
            ),
            child: Icon(icon, color: const Color(0xFF090A0F), size: 18),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle!,
              style: GoogleFonts.inter(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.large),
        child: card,
      );
    }
    return card;
  }
}

// =============================================================================
// REFOCUS SECTION HEADER
// =============================================================================
class RefocusSectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;
  final Color? accentColor;

  const RefocusSectionHeader({
    super.key,
    required this.title,
    this.actionText,
    this.onAction,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.inter(
            color: accentColor ?? AppColors.secondary,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              children: [
                Text(
                  actionText!,
                  style: GoogleFonts.inter(
                    color: AppColors.neonMint,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 11,
                  color: AppColors.neonMint,
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// =============================================================================
// REFOCUS PROGRESS RING / TIMER (Neo-Brutalism Chunky Stroke & Solid Colors)
// =============================================================================
class RefocusProgressRing extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final String timeText;
  final String? subtitle;
  final double size;
  final double strokeWidth;

  const RefocusProgressRing({
    super.key,
    required this.progress,
    required this.timeText,
    this.subtitle,
    this.size = 260.0,
    this.strokeWidth = 14.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hard Shadow Circle (Neo-brutalist solid offset)
          Container(
            width: size - strokeWidth,
            height: size - strokeWidth,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF000000),
                  offset: Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          // Custom Painted Progress Ring
          CustomPaint(
            size: Size(size, size),
            painter: _RefocusRingPainter(
              progress: progress.clamp(0.0, 1.0),
              strokeWidth: strokeWidth,
            ),
          ),
          // Center Text Readout
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeText,
                style: GoogleFonts.outfit(
                  color: AppColors.textPrimary,
                  fontSize: 54,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.5,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  subtitle!,
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _RefocusRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;

  _RefocusRingPainter({
    required this.progress,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // 1. Background Track
    final trackPaint = Paint()
      ..color = AppColors.surfaceContainerHigh
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, trackPaint);

    // Track outer border
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius + strokeWidth / 2, borderPaint);
    canvas.drawCircle(center, radius - strokeWidth / 2, borderPaint);

    if (progress <= 0.0) return;

    // 2. Active Arc (Solid Neo-Brutalist Neon Mint)
    final rect = Rect.fromCircle(center: center, radius: radius);
    final activePaint = Paint()
      ..color = AppColors.neonMint
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final sweepAngle = 2 * 3.141592653589793 * progress;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-3.141592653589793 / 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, 0, sweepAngle, false, activePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _RefocusRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}

// =============================================================================
// REFOCUS BOTTOM NAVIGATION BAR (Neo-Brutalism Solid Blocks & 2px Border)
// =============================================================================
class RefocusBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const RefocusBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.timer_outlined, label: 'Focus'),
      _NavItem(icon: Icons.insights_rounded, label: 'Stats'),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 2.0),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF000000),
            offset: Offset(0, -4),
            blurRadius: 0,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = currentIndex == index;

              return InkWell(
                onTap: () => onTap(index),
                borderRadius: BorderRadius.circular(AppRadius.large),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.neonMint : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.large),
                    border: isSelected
                        ? Border.all(
                            color: const Color(0xFF000000),
                            width: 2.0,
                          )
                        : null,
                    boxShadow: isSelected
                        ? const [
                            BoxShadow(
                              color: Color(0xFF000000),
                              offset: Offset(2, 2),
                              blurRadius: 0,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        item.icon,
                        color: isSelected
                            ? const Color(0xFF090A0F)
                            : AppColors.textMuted,
                        size: 20,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 8),
                        Text(
                          item.label,
                          style: GoogleFonts.inter(
                            color: const Color(0xFF090A0F),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}

// =============================================================================
// REFOCUS EMPTY STATE
// =============================================================================
class RefocusEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const RefocusEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: AppRadius.largeRadius,
        border: Border.all(color: AppColors.border, width: 2.0),
        boxShadow: const [AppShadows.cardShadow],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppRadius.large),
              border: Border.all(color: AppColors.border, width: 2.0),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF000000),
                  offset: Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.neonMint, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.outfit(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: GoogleFonts.inter(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 20),
            RefocusButton(
              text: buttonText!,
              onPressed: onButtonPressed,
              variant: RefocusButtonVariant.secondary,
              isFullWidth: false,
              height: 44,
            ),
          ],
        ],
      ),
    );
  }
}

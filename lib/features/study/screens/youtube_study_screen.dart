import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/refocus_components.dart';

final studyModeEnabledProvider = StateProvider<bool>((ref) => true);
final studyCategoryFilterProvider = StateProvider<String>((ref) => 'All');

class StudyVideoItem {
  final String id;
  final String title;
  final String channel;
  final String duration;
  final String category;
  final String iconEmoji;
  final Color accentColor;

  const StudyVideoItem({
    required this.id,
    required this.title,
    required this.channel,
    required this.duration,
    required this.category,
    required this.iconEmoji,
    required this.accentColor,
  });
}

final studyVideos = [
  const StudyVideoItem(
    id: '1',
    title: 'Electrostatics & Electric Fields — Complete Marathon',
    channel: 'Physics Wallah',
    duration: '1h 45m',
    category: 'Physics',
    iconEmoji: '⚡',
    accentColor: AppColors.primary,
  ),
  const StudyVideoItem(
    id: '2',
    title: 'Calculus for Beginners — Full Course & Derivatives',
    channel: 'Khan Academy',
    duration: '2h 10m',
    category: 'Math',
    iconEmoji: '📐',
    accentColor: AppColors.accentCyan,
  ),
  const StudyVideoItem(
    id: '3',
    title: 'Data Structures & Algorithms in 60 Minutes',
    channel: 'freeCodeCamp',
    duration: '1h 12m',
    category: 'CS',
    iconEmoji: '💻',
    accentColor: AppColors.secondary,
  ),
  const StudyVideoItem(
    id: '4',
    title: 'Thermodynamics & Thermal Properties of Matter',
    channel: 'MIT OpenCourseWare',
    duration: '52m',
    category: 'Physics',
    iconEmoji: '🔥',
    accentColor: AppColors.amber,
  ),
  const StudyVideoItem(
    id: '5',
    title: 'Linear Algebra & Neural Networks Essence',
    channel: '3Blue1Brown',
    duration: '42m',
    category: 'Math',
    iconEmoji: '🧠',
    accentColor: AppColors.primaryLight,
  ),
  const StudyVideoItem(
    id: '6',
    title: 'Chemical Kinetics & Organic Reaction Mechanisms',
    channel: 'CrashCourse Chemistry',
    duration: '1h 05m',
    category: 'Chemistry',
    iconEmoji: '🧪',
    accentColor: AppColors.success,
  ),
];

class YouTubeStudyScreen extends ConsumerStatefulWidget {
  const YouTubeStudyScreen({super.key});

  @override
  ConsumerState<YouTubeStudyScreen> createState() => _YouTubeStudyScreenState();
}

class _YouTubeStudyScreenState extends ConsumerState<YouTubeStudyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final categories = ['All', 'Physics', 'Math', 'CS', 'Chemistry'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isStudyModeOn = ref.watch(studyModeEnabledProvider);
    final selectedCategory = ref.watch(studyCategoryFilterProvider);

    final filteredVideos = studyVideos.where((v) {
      final matchesCat = selectedCategory == 'All' || v.category == selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          v.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          v.channel.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCat && matchesSearch;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'YouTube Study Mode',
                      style: GoogleFonts.outfit(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Mode Switcher Pill
                  GestureDetector(
                    onTap: () {
                      ref.read(studyModeEnabledProvider.notifier).state = !isStudyModeOn;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isStudyModeOn
                            ? AppColors.primary.withOpacity(0.18)
                            : AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isStudyModeOn
                              ? AppColors.primary.withOpacity(0.4)
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isStudyModeOn ? AppColors.primary : AppColors.textMuted,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isStudyModeOn ? 'ON' : 'OFF',
                            style: GoogleFonts.inter(
                              color: isStudyModeOn ? AppColors.primaryLight : AppColors.textMuted,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Study Shield Banner
                    RefocusCard(
                      padding: const EdgeInsets.all(20),
                      gradient: AppGradients.heroGradient,
                      hasGlow: true,
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.18),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: AppColors.primary.withOpacity(0.3),
                              ),
                            ),
                            child: const Center(
                              child: Text('📚', style: TextStyle(fontSize: 24)),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Study Without Distractions',
                                  style: GoogleFonts.outfit(
                                    color: AppColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Only educational content is permitted. Shorts and feeds are shielded.',
                                  style: GoogleFonts.inter(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Search input
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search educational videos...',
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: AppColors.textSecondary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: categories.map((cat) {
                          final isSelected = selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: RefocusChip(
                              label: cat,
                              isSelected: isSelected,
                              onTap: () {
                                ref.read(studyCategoryFilterProvider.notifier).state = cat;
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section Title
                    RefocusSectionHeader(
                      title: 'Recommended for You',
                      accentColor: AppColors.secondary,
                    ),
                    const SizedBox(height: 14),

                    // Video Cards List
                    if (filteredVideos.isEmpty)
                      const RefocusEmptyState(
                        icon: Icons.ondemand_video_outlined,
                        title: 'No Videos Found',
                        description: 'Try searching with another keyword or category filter.',
                      )
                    else
                      ...filteredVideos.map((video) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: RefocusCard(
                            onTap: () {
                              _showStudySessionPrompt(context, video);
                            },
                            child: Row(
                              children: [
                                // Thumbnail / Icon Container
                                Container(
                                  width: 68,
                                  height: 68,
                                  decoration: BoxDecoration(
                                    color: video.accentColor.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: video.accentColor.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      video.iconEmoji,
                                      style: const TextStyle(fontSize: 30),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        video.title,
                                        style: GoogleFonts.inter(
                                          color: AppColors.textPrimary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Text(
                                            video.channel,
                                            style: GoogleFonts.inter(
                                              color: AppColors.textSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '•',
                                            style: TextStyle(color: AppColors.textMuted),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            video.duration,
                                            style: GoogleFonts.inter(
                                              color: AppColors.primaryLight,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.play_circle_fill_rounded,
                                  color: AppColors.primary,
                                  size: 32,
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: RefocusBottomNavigation(
        currentIndex: 2, // Study tab
        onTap: (index) {
          if (index == 0) context.go('/home');
          if (index == 1) context.go('/focus/setup');
          if (index == 2) context.go('/study');
          if (index == 3) context.go('/wellbeing');
        },
      ),
    );
  }

  void _showStudySessionPrompt(BuildContext context, StudyVideoItem video) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  video.iconEmoji,
                  style: const TextStyle(fontSize: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    video.title,
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Channel: ${video.channel} • Est. ${video.duration}',
              style: GoogleFonts.inter(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            RefocusButton(
              text: 'Start Focus Session on ${video.category}',
              icon: Icons.timer_outlined,
              onPressed: () {
                Navigator.pop(ctx);
                context.push('/focus/setup');
              },
            ),
            const SizedBox(height: 10),
            RefocusButton(
              text: 'Dismiss',
              variant: RefocusButtonVariant.ghost,
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }
}

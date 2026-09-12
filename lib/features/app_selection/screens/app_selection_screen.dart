import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../app/theme.dart';
import '../../../core/widgets/refocus_components.dart';
import '../providers/app_selection_provider.dart';
import '../widgets/app_list_tile.dart';

enum AppFilterType { all, selectedOnly, distracting }

class AppSelectionScreen extends ConsumerStatefulWidget {
  const AppSelectionScreen({super.key});

  @override
  ConsumerState<AppSelectionScreen> createState() => _AppSelectionScreenState();
}

class _AppSelectionScreenState extends ConsumerState<AppSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  AppFilterType _activeFilter = AppFilterType.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appSelectionProvider);
    final notifier = ref.read(appSelectionProvider.notifier);

    // Apply secondary chip filter if active
    final displayedApps = state.filteredApps.where((app) {
      if (_activeFilter == AppFilterType.selectedOnly) {
        return app.isSelected;
      }
      return true;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                  Text(
                    'Blocked Apps',
                    style: GoogleFonts.outfit(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                    tooltip: 'Rescan Apps',
                    onPressed: () => notifier.loadApps(),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                    color: AppColors.surfaceElevated,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    onSelected: (value) {
                      if (value == 'select_all') {
                        notifier.selectAll();
                      } else if (value == 'deselect_all') {
                        notifier.deselectAll();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'select_all',
                        child: Text(
                          'Select All',
                          style: GoogleFonts.inter(color: AppColors.textPrimary),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'deselect_all',
                        child: Text(
                          'Deselect All',
                          style: GoogleFonts.inter(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar (M3 Pill Shape)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
              child: TextField(
                controller: _searchController,
                onChanged: notifier.search,
                decoration: InputDecoration(
                  hintText: 'Search installed applications...',
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: const OutlineInputBorder(
                    borderRadius: AppRadius.fullRadius,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.fullRadius,
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderRadius: AppRadius.fullRadius,
                    borderSide: BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            notifier.search('');
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Filter Chips Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  RefocusChip(
                    label: 'All Apps (${state.allApps.length})',
                    isSelected: _activeFilter == AppFilterType.all,
                    onTap: () => setState(() => _activeFilter = AppFilterType.all),
                  ),
                  const SizedBox(width: 8),
                  RefocusChip(
                    label: 'Selected (${state.selectedCount})',
                    isSelected: _activeFilter == AppFilterType.selectedOnly,
                    activeColor: AppColors.primary,
                    onTap: () => setState(() => _activeFilter = AppFilterType.selectedOnly),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Apps List or Empty / Loading State
            Expanded(
              child: state.isLoading
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(color: AppColors.primary),
                          SizedBox(height: 16),
                          Text(
                            'Scanning installed apps...',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    )
                  : displayedApps.isEmpty
                      ? Center(
                          child: RefocusEmptyState(
                            icon: Icons.apps_outage_rounded,
                            title: 'No Apps Found',
                            description: state.searchQuery.isEmpty
                                ? (_activeFilter == AppFilterType.selectedOnly
                                    ? 'No applications currently selected. Tap any app to block it.'
                                    : 'No launchable applications detected.')
                                : 'No apps matching "${state.searchQuery}"',
                          ),
                        )
                      : ListView.builder(
                          itemCount: displayedApps.length,
                          itemBuilder: (context, index) {
                            final app = displayedApps[index];
                            return AppListTile(
                              app: app,
                              onToggle: (_) => notifier.toggleSelection(app.packageName),
                            );
                          },
                        ),
            ),

            // Bottom Sticky Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.backgroundSecondary,
                border: const Border(top: BorderSide(color: AppColors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${state.selectedCount} apps selected',
                            style: GoogleFonts.inter(
                              color: AppColors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Shielded during focus sessions',
                            style: GoogleFonts.inter(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RefocusButton(
                      text: 'Done',
                      isFullWidth: false,
                      height: 46,
                      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go('/home');
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tudu/features/navigation/application/navigation_provider.dart';
import 'package:tudu/features/today/presentation/screens/today_screen.dart';
import 'package:tudu/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:tudu/features/notes/presentation/screens/notes_screen.dart';
import 'package:tudu/features/settings/presentation/screens/settings_screen.dart';
import 'package:tudu/features/settings/application/update_provider.dart';
import 'package:tudu/features/settings/presentation/widgets/update_dialog.dart';
import 'package:tudu/shared/utils/date_utils.dart';

class NavigationShell extends StatefulWidget {
  const NavigationShell({super.key});

  @override
  State<NavigationShell> createState() => _NavigationShellState();
}

class _NavigationShellState extends State<NavigationShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutoUpdate();
    });
  }

  Future<void> _checkAutoUpdate() async {
    final updateProvider = Provider.of<UpdateProvider>(context, listen: false);
    if (updateProvider.autoCheckOnStartup && !updateProvider.hasPromptedThisSession) {
      updateProvider.markPrompted();
      final info = await updateProvider.checkForUpdates();
      if (info != null && info.isUpdateAvailable && mounted) {
        AppUpdateDialog.show(context, info);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    
    // Choose layout based on width
    if (width < 600) {
      return const _MobileNavigationLayout();
    } else if (width < 1024) {
      return const _TabletNavigationLayout();
    } else {
      return const _DesktopNavigationLayout();
    }
  }
}

/// Helper method to return the active screen based on the selected tab
Widget _getScreenForTab(NavigationTab tab) {
  switch (tab) {
    case NavigationTab.today:
      return const TodayScreen();
    case NavigationTab.tasks:
      return const TasksScreen();
    case NavigationTab.notes:
      return const NotesScreen();
    case NavigationTab.settings:
      return const SettingsScreen();
  }
}

/// Animated transition wrapper for changing screens
Widget _buildAnimatedContent(NavigationTab tab) {
  return AnimatedSwitcher(
    duration: const Duration(milliseconds: 250),
    switchInCurve: Curves.easeInOutCubic,
    switchOutCurve: Curves.easeInOutCubic,
    transitionBuilder: (child, animation) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    child: KeyedSubtree(
      key: ValueKey<NavigationTab>(tab),
      child: _getScreenForTab(tab),
    ),
  );
}

// ==========================================
// 📱 Mobile Navigation Layout (< 600px)
// ==========================================
class _MobileNavigationLayout extends StatelessWidget {
  const _MobileNavigationLayout();

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);

    return Scaffold(
      body: _buildAnimatedContent(navigationProvider.currentTab),
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationProvider.currentIndex,
        onDestinationSelected: (index) {
          navigationProvider.setIndex(index);
        },
        destinations: [
          NavigationDestination(
            icon: Icon(AppDateUtils.isNight() ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined),
            selectedIcon: Icon(AppDateUtils.isNight() ? Icons.nights_stay : Icons.wb_sunny),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_note_outlined),
            selectedIcon: Icon(Icons.edit_note),
            label: 'Notes',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 📟 Tablet Navigation Layout (600px - 1023px)
// ==========================================
class _TabletNavigationLayout extends StatelessWidget {
  const _TabletNavigationLayout();

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: navigationProvider.currentIndex,
            onDestinationSelected: (index) {
              navigationProvider.setIndex(index);
            },
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.done_all,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
            destinations: [
              NavigationRailDestination(
                icon: Icon(AppDateUtils.isNight() ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined),
                selectedIcon: Icon(AppDateUtils.isNight() ? Icons.nights_stay : Icons.wb_sunny),
                label: const Text('Today'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.task_alt_outlined),
                selectedIcon: Icon(Icons.task_alt),
                label: Text('Tasks'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.edit_note_outlined),
                selectedIcon: Icon(Icons.edit_note),
                label: Text('Notes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildAnimatedContent(navigationProvider.currentTab),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 💻 Desktop Navigation Layout (>= 1024px)
// ==========================================
class _DesktopNavigationLayout extends StatelessWidget {
  const _DesktopNavigationLayout();

  @override
  Widget build(BuildContext context) {
    final navigationProvider = Provider.of<NavigationProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          SafeArea(
            child: SizedBox(
              width: 250,
              child: Container(
                color: theme.navigationBarTheme.backgroundColor ?? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Desktop Header App Logo
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.done_all,
                            color: theme.colorScheme.primary,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Tudu',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    
                    // Sidebar Navigation Options
                    _DesktopDrawerTile(
                      icon: AppDateUtils.isNight() ? Icons.nights_stay_outlined : Icons.wb_sunny_outlined,
                      selectedIcon: AppDateUtils.isNight() ? Icons.nights_stay : Icons.wb_sunny,
                      label: 'Today',
                      selected: navigationProvider.currentTab == NavigationTab.today,
                      onTap: () => navigationProvider.setTab(NavigationTab.today),
                    ),
                    _DesktopDrawerTile(
                      icon: Icons.task_alt_outlined,
                      selectedIcon: Icons.task_alt,
                      label: 'Tasks',
                      selected: navigationProvider.currentTab == NavigationTab.tasks,
                      onTap: () => navigationProvider.setTab(NavigationTab.tasks),
                    ),
                    _DesktopDrawerTile(
                      icon: Icons.edit_note_outlined,
                      selectedIcon: Icons.edit_note,
                      label: 'Notes',
                      selected: navigationProvider.currentTab == NavigationTab.notes,
                      onTap: () => navigationProvider.setTab(NavigationTab.notes),
                    ),
                    _DesktopDrawerTile(
                      icon: Icons.settings_outlined,
                      selectedIcon: Icons.settings,
                      label: 'Settings',
                      selected: navigationProvider.currentTab == NavigationTab.settings,
                      onTap: () => navigationProvider.setTab(NavigationTab.settings),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _buildAnimatedContent(navigationProvider.currentTab),
          ),
        ],
      ),
    );
  }
}

class _DesktopDrawerTile extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopDrawerTile({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      child: Material(
        color: selected ? theme.colorScheme.primaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                Icon(
                  selected ? selectedIcon : icon,
                  color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                const SizedBox(width: 16),
                Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
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

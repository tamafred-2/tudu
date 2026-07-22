import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tudu/features/categories/presentation/widgets/category_manager_sheet.dart';
import 'package:tudu/features/notifications/application/notifications_provider.dart';
import 'package:tudu/features/settings/application/settings_provider.dart';
import 'package:tudu/features/settings/application/update_provider.dart';
import 'package:tudu/features/settings/presentation/widgets/update_dialog.dart';
import 'package:tudu/shared/theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showBackupRestoreSheet(BuildContext context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Backup & Restore',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Save your local task list and notes to a backup file, or restore them later.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.download_rounded, color: Colors.teal),
                  title: const Text('Backup Data'),
                  subtitle: const Text('Download local backup file (tudu_backup.json)'),
                  onTap: () {
                    Navigator.pop(context);
                    _runBackupSimulation(context);
                  },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.upload_rounded, color: Colors.blue),
                  title: const Text('Restore Data'),
                  subtitle: const Text('Import settings, tasks, and notes from file'),
                  onTap: () {
                    Navigator.pop(context);
                    _runRestoreSimulation(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _runBackupSimulation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text('Generating backup data file...'),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        Navigator.pop(context); // Close backup dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup file (tudu_backup.json) saved successfully!'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _runRestoreSimulation(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Expanded(
                child: Text('Restoring tasks, notes, and labels...'),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (context.mounted) {
        Navigator.pop(context); // Close restore dialog
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data restored successfully! Loaded settings & configs.'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final notificationsProvider = Provider.of<NotificationsProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final updateProvider = Provider.of<UpdateProvider>(context);

    String getThemeModeName(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.system:
          return 'System Default';
        case ThemeMode.light:
          return 'Light Mode';
        case ThemeMode.dark:
          return 'Dark Mode';
      }
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          // Section: Appearance
          _buildSectionHeader(context, 'Appearance'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.palette_outlined),
                  title: const Text('Theme Mode'),
                  subtitle: Text(getThemeModeName(themeProvider.themeMode)),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return SimpleDialog(
                          title: const Text('Select Theme Mode'),
                          children: ThemeMode.values.map((mode) {
                            return SimpleDialogOption(
                              onPressed: () {
                                themeProvider.setThemeMode(mode);
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    mode == ThemeMode.system
                                        ? Icons.brightness_auto
                                        : mode == ThemeMode.light
                                            ? Icons.light_mode
                                            : Icons.dark_mode,
                                  ),
                                  const SizedBox(width: 16),
                                  Text(getThemeModeName(mode)),
                                  if (themeProvider.themeMode == mode) ...[
                                    const Spacer(),
                                    Icon(Icons.check, color: theme.colorScheme.primary),
                                  ]
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.volume_up_outlined),
                  title: const Text('Sound Effects'),
                  subtitle: const Text('Play sound on task completion'),
                  value: settingsProvider.soundEffectsEnabled,
                  onChanged: (val) {
                    settingsProvider.toggleSoundEffects(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section: General
          _buildSectionHeader(context, 'General'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.label_outline),
                  title: const Text('Manage Categories'),
                  subtitle: const Text('Customize category names and colors'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CategoryManagerSheet(),
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 56),
                
                // Notifications switch tile
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Daily Reminder'),
                  subtitle: const Text('Get notified of tasks due today/overdue'),
                  value: notificationsProvider.isDailyReminderEnabled,
                  onChanged: (val) {
                    notificationsProvider.toggleDailyReminder(val);
                  },
                ),
                
                if (notificationsProvider.isDailyReminderEnabled) ...[
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Reminder Time'),
                    subtitle: Text(
                      '${notificationsProvider.reminderHour.toString().padLeft(2, '0')}:${notificationsProvider.reminderMinute.toString().padLeft(2, '0')}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay(
                          hour: notificationsProvider.reminderHour,
                          minute: notificationsProvider.reminderMinute,
                        ),
                      );
                      if (picked != null) {
                        notificationsProvider.updateReminderTime(
                          picked.hour,
                          picked.minute,
                        );
                      }
                    },
                  ),
                  const Divider(height: 1, indent: 56),
                  ListTile(
                    leading: const Icon(Icons.notification_important_outlined),
                    title: const Text('Send Test Notification'),
                    subtitle: const Text('Trigger a test notification now'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      notificationsProvider.sendTestNotification();
                    },
                  ),
                ],
                
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.cloud_queue),
                  title: const Text('Backup & Restore'),
                  subtitle: const Text('Simulate data download & restoration'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showBackupRestoreSheet(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section: App Updates
          _buildSectionHeader(context, 'App Updates'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: updateProvider.isChecking
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : Icon(
                          updateProvider.hasUpdate
                              ? Icons.system_update_rounded
                              : Icons.system_update_outlined,
                          color: updateProvider.hasUpdate ? theme.colorScheme.primary : null,
                        ),
                  title: const Text('Check for Updates'),
                  subtitle: Text(
                    updateProvider.isChecking
                        ? 'Checking for new releases on GitHub...'
                        : updateProvider.hasUpdate
                            ? 'New update available! (v${updateProvider.latestUpdateInfo?.latestVersion})'
                            : 'Current version: v${UpdateProvider.currentAppVersion} (Latest)',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: updateProvider.isChecking
                      ? null
                      : () async {
                          final info = await updateProvider.checkForUpdates(manual: true);
                          if (context.mounted) {
                            if (info != null && info.isUpdateAvailable) {
                              AppUpdateDialog.show(context, info);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('🎉 You are using the latest version of Tudu!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        },
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.science_outlined, color: Colors.deepPurple),
                  title: const Text('Test Update Alert Modal'),
                  subtitle: const Text('Preview how the update notification dialog looks'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    final testInfo = updateProvider.simulateTestUpdate();
                    AppUpdateDialog.show(context, testInfo);
                  },
                ),
                const Divider(height: 1, indent: 56),
                SwitchListTile(
                  secondary: const Icon(Icons.autorenew_rounded),
                  title: const Text('Auto-check on Startup'),
                  subtitle: const Text('Automatically check for GitHub updates when app opens'),
                  value: updateProvider.autoCheckOnStartup,
                  onChanged: (val) {
                    updateProvider.toggleAutoCheck(val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Section: About
          _buildSectionHeader(context, 'About'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('Version'),
                  trailing: Text(
                    '1.0.0',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Developer'),
                  subtitle: const Text('Alfred M. Tamayo'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showDeveloperInfoDialog(context),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.code),
                  title: const Text('Built with'),
                  subtitle: const Text('Flutter, Dart & Material 3'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeveloperInfoDialog(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/tudu-icon/rounded/icon-rounded-512.png',
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(width: 12),
            const Text('About Tudu'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tudu — Your cozy space for focus',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'A modern cross-platform productivity app for managing '
              'daily tasks and notes, designed around simplicity and '
              'everyday organization.',
            ),
            const SizedBox(height: 16),
            Text(
              'Developed & designed by',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Alfred M. Tamayo',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Built with Flutter, Dart & Material 3\nVersion 1.0.0 (Beta)',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

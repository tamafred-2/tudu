import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool isUpdateAvailable;
  final String releaseTitle;
  final String releaseNotes;
  final String updateUrl;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.isUpdateAvailable,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.updateUrl,
  });
}

class UpdateProvider with ChangeNotifier {
  static const String currentAppVersion = '1.0.0';
  static const String githubRepo = 'tamafred-2/tudu';

  bool _isChecking = false;
  bool _hasUpdate = false;
  UpdateInfo? _latestUpdateInfo;
  bool _autoCheckOnStartup = true;
  bool _hasPromptedThisSession = false;

  UpdateProvider() {
    _loadSettings();
  }

  bool get isChecking => _isChecking;
  bool get hasUpdate => _hasUpdate;
  UpdateInfo? get latestUpdateInfo => _latestUpdateInfo;
  bool get autoCheckOnStartup => _autoCheckOnStartup;
  bool get hasPromptedThisSession => _hasPromptedThisSession;

  void markPrompted() {
    _hasPromptedThisSession = true;
    notifyListeners();
  }

  UpdateInfo simulateTestUpdate() {
    final info = UpdateInfo(
      currentVersion: currentAppVersion,
      latestVersion: '1.1.0',
      isUpdateAvailable: true,
      releaseTitle: 'Tudu v1.1.0 Feature Release 🚀',
      releaseNotes: '• Sun-to-Moon day/night icon transitions\n• Task start & end time ranges\n• 30-min advance & exact start scheduled reminders\n• GitHub in-app update checker & alert dialogs',
      updateUrl: 'https://github.com/$githubRepo/releases/latest',
    );
    _latestUpdateInfo = info;
    _hasUpdate = true;
    notifyListeners();
    return info;
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _autoCheckOnStartup = prefs.getBool('auto_check_updates') ?? true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load update settings: $e');
    }
  }

  Future<void> toggleAutoCheck(bool value) async {
    _autoCheckOnStartup = value;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('auto_check_updates', value);
    } catch (e) {
      debugPrint('Failed to save update settings: $e');
    }
  }

  /// Compares two semantic version strings (e.g. '1.0.0' vs '1.1.0').
  /// Returns true if [latest] is strictly newer than [current].
  static bool isNewerVersion(String current, String latest) {
    try {
      final currentClean = current.replaceAll(RegExp(r'[^0-9.]'), '');
      final latestClean = latest.replaceAll(RegExp(r'[^0-9.]'), '');

      final currentParts = currentClean.split('.').map(int.parse).toList();
      final latestParts = latestClean.split('.').map(int.parse).toList();

      final maxLength = currentParts.length > latestParts.length
          ? currentParts.length
          : latestParts.length;

      for (int i = 0; i < maxLength; i++) {
        final currentVal = i < currentParts.length ? currentParts[i] : 0;
        final latestVal = i < latestParts.length ? latestParts[i] : 0;

        if (latestVal > currentVal) return true;
        if (latestVal < currentVal) return false;
      }
      return false;
    } catch (e) {
      debugPrint('Error comparing versions ($current vs $latest): $e');
      return false;
    }
  }

  /// Checks GitHub API for the latest release.
  Future<UpdateInfo?> checkForUpdates({bool manual = false}) async {
    if (_isChecking) return _latestUpdateInfo;

    _isChecking = true;
    notifyListeners();

    UpdateInfo? resultInfo;

    try {
      final uri = Uri.parse('https://api.github.com/repos/$githubRepo/releases/latest');
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 8);

      final request = await client.getUrl(uri);
      request.headers.set('User-Agent', 'TuduApp-UpdateChecker');
      request.headers.set('Accept', 'application/vnd.github+json');

      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final json = jsonDecode(responseBody) as Map<String, dynamic>;

        final tagName = (json['tag_name'] as String? ?? 'v1.0.0').replaceAll('v', '');
        final releaseTitle = json['name'] as String? ?? 'v$tagName Release';
        final releaseNotes = json['body'] as String? ?? 'New version available on GitHub.';
        final htmlUrl = json['html_url'] as String? ?? 'https://github.com/$githubRepo/releases/latest';

        final bool newVersionAvailable = isNewerVersion(currentAppVersion, tagName);

        resultInfo = UpdateInfo(
          currentVersion: currentAppVersion,
          latestVersion: tagName,
          isUpdateAvailable: newVersionAvailable,
          releaseTitle: releaseTitle,
          releaseNotes: releaseNotes,
          updateUrl: htmlUrl,
        );
      } else {
        // Fallback for offline or 404 repo
        resultInfo = UpdateInfo(
          currentVersion: currentAppVersion,
          latestVersion: currentAppVersion,
          isUpdateAvailable: false,
          releaseTitle: 'Tudu v$currentAppVersion',
          releaseNotes: 'You are using the latest version.',
          updateUrl: 'https://github.com/$githubRepo/releases',
        );
      }
      client.close();
    } catch (e) {
      debugPrint('Failed to check GitHub updates: $e');
      resultInfo = UpdateInfo(
        currentVersion: currentAppVersion,
        latestVersion: currentAppVersion,
        isUpdateAvailable: false,
        releaseTitle: 'Tudu v$currentAppVersion',
        releaseNotes: 'Could not connect to update server.',
        updateUrl: 'https://github.com/$githubRepo/releases',
      );
    } finally {
      _isChecking = false;
      _latestUpdateInfo = resultInfo;
      _hasUpdate = resultInfo?.isUpdateAvailable ?? false;
      notifyListeners();
    }

    return resultInfo;
  }

  /// Launch update URL in browser or default OS browser handler
  static Future<void> launchUrl(String url) async {
    try {
      if (kIsWeb) {
        // Handled via Web HTML launcher or window.open in web environment
      } else {
        if (Platform.isWindows) {
          await Process.run('cmd', ['/c', 'start', '', url]);
        } else if (Platform.isMacOS) {
          await Process.run('open', [url]);
        } else if (Platform.isLinux) {
          await Process.run('xdg-open', [url]);
        }
      }
    } catch (e) {
      debugPrint('Failed to launch URL: $e');
    }
  }
}

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
  final String? downloadUrl;
  final String? fileName;

  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.isUpdateAvailable,
    required this.releaseTitle,
    required this.releaseNotes,
    required this.updateUrl,
    this.downloadUrl,
    this.fileName,
  });
}

class UpdateProvider with ChangeNotifier {
  static const String currentAppVersion = '1.1.0';
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
      latestVersion: '1.1.1',
      isUpdateAvailable: true,
      releaseTitle: 'Tudu v1.1.1 Patch Release 🚀',
      releaseNotes: '• Direct in-app update downloading & installer launch\n• Home screen widget optimizations\n• Performance enhancements',
      updateUrl: 'https://github.com/$githubRepo/releases/latest',
      downloadUrl: 'simulate://tudu-test-update',
      fileName: Platform.isWindows ? 'tudu-windows.zip' : 'tudu-release.apk',
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

  /// Checks GitHub API for the latest release and matches release assets for current OS.
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

        String? assetDownloadUrl;
        String? assetFileName;

        if (json.containsKey('assets') && json['assets'] is List) {
          final assets = json['assets'] as List;
          for (final asset in assets) {
            if (asset is Map<String, dynamic>) {
              final name = (asset['name'] as String? ?? '').toLowerCase();
              final downloadUrl = asset['browser_download_url'] as String?;

              if (downloadUrl != null && downloadUrl.isNotEmpty) {
                if (kIsWeb) {
                  assetDownloadUrl = downloadUrl;
                  assetFileName = asset['name'] as String?;
                  break;
                } else if (Platform.isWindows && (name.endsWith('.zip') || name.endsWith('.exe'))) {
                  assetDownloadUrl = downloadUrl;
                  assetFileName = asset['name'] as String?;
                  break;
                } else if (Platform.isAndroid && name.endsWith('.apk')) {
                  assetDownloadUrl = downloadUrl;
                  assetFileName = asset['name'] as String?;
                  break;
                }
              }
            }
          }
          // Fallback to first asset if no OS-specific match found
          if (assetDownloadUrl == null && assets.isNotEmpty && assets.first is Map) {
            final firstAsset = assets.first as Map<String, dynamic>;
            assetDownloadUrl = firstAsset['browser_download_url'] as String?;
            assetFileName = firstAsset['name'] as String?;
          }
        }

        final bool newVersionAvailable = isNewerVersion(currentAppVersion, tagName);

        // Guarantee a direct download URL even if release assets list was not explicitly populated
        if (assetDownloadUrl == null || assetDownloadUrl.isEmpty) {
          final defaultFileName = Platform.isWindows ? 'tudu-windows.zip' : 'app-release.apk';
          assetDownloadUrl = 'https://github.com/$githubRepo/releases/download/v$tagName/$defaultFileName';
          assetFileName = defaultFileName;
        }

        resultInfo = UpdateInfo(
          currentVersion: currentAppVersion,
          latestVersion: tagName,
          isUpdateAvailable: newVersionAvailable,
          releaseTitle: releaseTitle,
          releaseNotes: releaseNotes,
          updateUrl: htmlUrl,
          downloadUrl: assetDownloadUrl,
          fileName: assetFileName,
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

  /// Downloads the release file to system temporary directory with real-time progress.
  /// Handles cross-domain HTTP 302/301 redirects (e.g. GitHub to AWS S3) & simulated downloads.
  static Future<String> downloadUpdateFile(
    String downloadUrl,
    String fileName, {
    required void Function(double progress) onProgress,
  }) async {
    final tempDir = Directory.systemTemp;
    final saveFile = File('${tempDir.path}${Platform.pathSeparator}$fileName');
    if (await saveFile.exists()) {
      try {
        await saveFile.delete();
      } catch (_) {}
    }

    // Handle simulated test downloads
    if (downloadUrl.startsWith('simulate:')) {
      for (int step = 1; step <= 10; step++) {
        await Future.delayed(const Duration(milliseconds: 150));
        onProgress(step / 10.0);
      }
      await saveFile.writeAsString('Tudu v1.1.1 Test Release Package');
      return saveFile.path;
    }

    final client = HttpClient();
    client.connectionTimeout = const Duration(seconds: 20);

    String currentUrl = downloadUrl;
    HttpClientResponse? response;

    // Follow up to 5 HTTP redirects (GitHub Releases redirect to AWS S3)
    for (int i = 0; i < 5; i++) {
      final request = await client.getUrl(Uri.parse(currentUrl));
      request.headers.set('User-Agent', 'TuduApp-UpdateDownloader');
      request.followRedirects = false; // Handle redirects manually across domains

      final res = await request.close();
      if (res.statusCode >= 300 && res.statusCode < 400) {
        final redirectLocation = res.headers.value(HttpHeaders.locationHeader);
        if (redirectLocation != null && redirectLocation.isNotEmpty) {
          currentUrl = redirectLocation;
          continue;
        }
      }
      response = res;
      break;
    }

    if (response == null || response.statusCode != 200) {
      client.close();
      throw Exception('HTTP ${response?.statusCode ?? 'Unknown'} downloading update file');
    }

    final contentLength = response.contentLength;
    int bytesDownloaded = 0;
    final sink = saveFile.openWrite();

    await for (final chunk in response) {
      bytesDownloaded += chunk.length;
      sink.add(chunk);
      if (contentLength > 0) {
        final progress = bytesDownloaded / contentLength;
        onProgress(progress.clamp(0.0, 1.0));
      } else {
        onProgress(-1); // Indeterminate length
      }
    }

    await sink.flush();
    await sink.close();
    client.close();

    return saveFile.path;
  }

  /// Opens or executes the downloaded file on system (Windows/Android/macOS).
  static Future<bool> openDownloadedFile(String filePath) async {
    try {
      if (kIsWeb) return false;

      if (Platform.isWindows) {
        final result = await Process.run('cmd', ['/c', 'start', '', filePath]);
        return result.exitCode == 0;
      } else if (Platform.isAndroid) {
        final result = await Process.run('am', ['start', '-a', 'android.intent.action.VIEW', '-d', 'file://$filePath', '-t', 'application/vnd.android.package-archive']);
        return result.exitCode == 0;
      } else if (Platform.isMacOS) {
        final result = await Process.run('open', [filePath]);
        return result.exitCode == 0;
      } else if (Platform.isLinux) {
        final result = await Process.run('xdg-open', [filePath]);
        return result.exitCode == 0;
      }
      return false;
    } catch (e) {
      debugPrint('Error opening downloaded file: $e');
      return false;
    }
  }

  /// Launch update URL in browser as fallback
  static Future<void> launchUrl(String url) async {
    try {
      if (kIsWeb) {
        // Handled via Web HTML launcher or window.open
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


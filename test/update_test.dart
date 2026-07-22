import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudu/features/settings/application/update_provider.dart';
import 'package:tudu/features/settings/presentation/widgets/update_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UpdateProvider Semantic Version Tests', () {
    test('isNewerVersion compares versions correctly', () {
      expect(UpdateProvider.isNewerVersion('1.0.0', '1.1.0'), true);
      expect(UpdateProvider.isNewerVersion('1.0.0', '1.0.1'), true);
      expect(UpdateProvider.isNewerVersion('1.0.0', '2.0.0'), true);
      expect(UpdateProvider.isNewerVersion('1.1.0', '1.0.0'), false);
      expect(UpdateProvider.isNewerVersion('1.0.0', '1.0.0'), false);
      expect(UpdateProvider.isNewerVersion('1.0.0', 'v1.0.1'), true);
    });

    test('UpdateProvider initial state', () async {
      SharedPreferences.setMockInitialValues({});
      final provider = UpdateProvider();
      expect(provider.isChecking, false);
      expect(provider.hasUpdate, false);
      expect(provider.autoCheckOnStartup, true);
    });
  });

  group('AppUpdateDialog Widget Tests', () {
    testWidgets('Renders update dialog with version and action buttons', (WidgetTester tester) async {
      const updateInfo = UpdateInfo(
        currentVersion: '1.0.0',
        latestVersion: '1.1.0',
        isUpdateAvailable: true,
        releaseTitle: 'v1.1.0 Feature Release',
        releaseNotes: 'Added new theme options and task timers.',
        updateUrl: 'https://github.com/tamafred-2/tudu/releases/latest',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppUpdateDialog(updateInfo: updateInfo),
          ),
        ),
      );

      expect(find.text('Update Available! 🚀'), findsOneWidget);
      expect(find.text('Version v1.1.0'), findsOneWidget);
      expect(find.text('v1.1.0 Feature Release'), findsOneWidget);
      expect(find.text('Added new theme options and task timers.'), findsOneWidget);
      expect(find.text('Later'), findsOneWidget);
      expect(find.text('Update Now'), findsOneWidget);
    });
  });
}

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/navigation/application/navigation_provider.dart';
import 'features/navigation/presentation/screens/animated_splash_screen.dart';
import 'features/tasks/application/tasks_provider.dart';
import 'features/notes/application/notes_provider.dart';
import 'features/categories/application/categories_provider.dart';
import 'features/notifications/application/notification_service.dart';
import 'features/notifications/application/notifications_provider.dart';
import 'features/settings/application/settings_provider.dart';
import 'shared/theme/theme.dart';
import 'shared/theme/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService.instance.init();
  runApp(const MyApp());
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => TasksProvider()),
        ChangeNotifierProvider(create: (_) => NotesProvider()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProxyProvider<TasksProvider, NotificationsProvider>(
          create: (_) => NotificationsProvider(),
          update: (_, tasksProvider, notificationsProvider) {
            notificationsProvider!.startReminderTimer(tasksProvider);
            return notificationsProvider;
          },
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Tudu',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            scrollBehavior: const AppScrollBehavior(),
            home: const AnimatedSplashScreen(),
          );
        },
      ),
    );
  }
}

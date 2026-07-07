Tudu app icon (design 3b — double check)
Colors: bg #0F5A47, checks #45A285 / #CDE8E0

Easiest path (Flutter): add flutter_launcher_icons to pubspec.yaml and point it
at icon-master-1024.png:

  dev_dependencies:
    flutter_launcher_icons: ^0.14.1

  flutter_launcher_icons:
    android: true
    ios: true
    windows:
      generate: true
    macos:
      generate: true
    image_path: "assets/icon/icon-master-1024.png"
    adaptive_icon_background: "#0F5A47"
    adaptive_icon_foreground: "assets/icon/ic_launcher_foreground-432.png"

Then run: dart run flutter_launcher_icons

Folders:
- icon-master-1024.png     master square, use as image_path
- rounded/                 pre-rounded PNGs for web/desktop/docs
- icon-circle-512.png      circular variant
- android-adaptive/        adaptive icon layers (fg glyph in safe zone + bg)
- android-legacy/          plain launcher PNGs per density

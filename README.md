# Tudu

> A modern cross-platform productivity app built with Flutter, designed to help users manage daily tasks and notes across Windows, Android, and the web — usable on iPhone, iPad, Mac, and Linux through the browser.

![Status](https://img.shields.io/badge/status-active%20development-brightgreen)
![Platform](https://img.shields.io/badge/platform-cross--platform-02569B?logo=flutter&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)
![Material 3](https://img.shields.io/badge/UI-Material%203-6750A4)
![License](https://img.shields.io/badge/license-portfolio-lightgrey)

---

# 📖 Overview

Tudu is a lightweight productivity app focused on simplicity and everyday organization.

Instead of overwhelming users with unnecessary features, Tudu provides a cozy and enjoyable environment for managing tasks, taking notes, and staying organized.

Built with Flutter, the project shares a single codebase across multiple platforms while following a scalable architecture and modern UI principles.

---

# 📥 Download (BETA)

You can download and run Tudu directly on your devices:

| Platform | How to get it |
|---|---|
| 📱 Android | [Download the APK](app-release.apk) |
| 💻 Windows | [Download the ZIP](tudu-windows.zip) |
| 🌐 Web (any device) | [Open in browser](https://tamafred-2.github.io/tudu/) |
| 🍎 iPhone / iPad / Mac | Use the [web version](https://tamafred-2.github.io/tudu/) (Add to Home Screen) |
| 🐧 Linux | Use the [web version](https://tamafred-2.github.io/tudu/) or build from source |

### 📱 Android
* **[Download Tudu for Android (APK)](app-release.apk)** 
  *(Note: Requires the compiled `app-release.apk` to be in the project root folder. Clicking this link on your phone downloads the app installer directly).*

> [!NOTE]
> **Android Installation Steps:**
> 1. Click the download link above on your Android phone.
> 2. Open the downloaded `.apk` file.
> 3. If prompted by your device, allow installing applications from your browser or file manager ("Allow from this source").
> 4. Select **Install**, open the app, and enjoy Tudu!

### 💻 Windows Desktop
* **[Download Tudu for Windows (ZIP)](tudu-windows.zip)**

> [!NOTE]
> **Windows Installation Steps:**
> 1. Click the download link above and save the ZIP file.
> 2. Right-click the downloaded `tudu-windows.zip` and select **Extract All...**
> 3. Open the extracted folder and double-click **`tudu.exe`** to launch the app.
> 4. If Windows SmartScreen appears, click **More info** → **Run anyway** (the app is unsigned, which is normal for beta releases).
>
> No compiling or extra tools needed — the ZIP already contains the ready-to-run app.

### 🌐 Web — iPhone, iPad, Mac, Linux & everything else
* **[Open Tudu in your browser](https://tamafred-2.github.io/tudu/)** — no install needed, works on any device with a modern browser.

> [!TIP]
> On iPhone/iPad (Safari) or Android (Chrome), use **Share → Add to Home Screen** to install Tudu like a real app, with its own icon and full-screen experience.

### 🍎 macOS / 🐧 Linux (native)
Native desktop builds are supported by the codebase but not distributed yet (they must be compiled on their own platform). Use the web version above, or build from source:

```bash
flutter pub get
flutter build macos --release   # on a Mac
flutter build linux --release   # on Linux
```

---

## 🏗️ Architecture

This application follows a **Feature-First Layered Architecture**.

```text
Presentation
├── Screens
├── Widgets
└── Material 3 UI

Application
├── Provider
├── State Management
└── Navigation

Business
├── Models
├── Business Logic
└── Utilities

Data Access
├── Repositories
├── Local Storage
└── Services

Database
├── Hive
└── SQLite
```

---

## 🛠️ Tech Stack

- Flutter
- Dart
- Material 3
- Provider
- Hive
- SQLite
- flutter_local_notifications
- audioplayers
- Git
- GitHub

## 🧪 Run locally

### Windows

```powershell
flutter pub get
flutter build windows --release
```

### Android / mobile

```powershell
flutter pub get
flutter run
```

> For Windows builds, make sure Visual Studio Build Tools with the Desktop development with C++ workload are installed.

---

## 🚀 Planned Features

### 📋 Tasks

- Create, edit, and delete tasks
- Mark tasks as completed
- Today view
- Due dates
- Categories & labels
- Task search
- Priority levels

### 📝 Notes

- Create and edit notes
- Rich text support *(planned)*
- Checklists
- Search notes
- Pin important notes

### 🎨 User Experience

- Cozy minimal interface
- Light & dark themes
- Smooth animations
- Task completion sound effects
- Responsive layouts
- Material 3 design

### 🔔 Productivity

- Local notifications
- Daily reminders
- Productivity insights
- Calendar view *(planned)*
- Recurring tasks *(planned)*

### ⚙️ Settings

- Theme customization
- Notification preferences
- Data backup & restore *(planned)*
- About & app information

### ☁️ Future

- Cloud synchronization
- Cross-device sync
- User authentication
- Multiple workspaces
- Home screen widgets
- Export & import data

---

## 📅 Roadmap

- [x] Project planning
- [x] Project initialization
- [x] App navigation
- [x] Task management
- [x] Notes management
- [x] Categories & labels
- [x] Search functionality
- [x] Today view
- [x] Due dates
- [x] Local notifications
- [x] Light & dark themes
- [x] Settings
- [x] Local data persistence
- [x] Task completion sound effects
- [x] Animations & UI polish
- [x] Performance optimization
- [x] Testing
- [x] Cross-platform support (Windows, Android, iOS, Web & Desktop)
- [x] Release v1.0.0

### 🎯 Next Version (v1.1) — Milestones

- [ ] **Backup & Restore to the cloud** — save and restore your tasks & notes using a free cloud service (Google Drive first, since it's free and most users already have it)
- [ ] Export & import data as a local file (JSON) — works offline, no account needed
- [ ] Recurring tasks
- [ ] Calendar view
- [ ] Rich text support for notes
- [ ] Home screen widgets (Android)
- [ ] Reminders that work even when the app is closed (scheduled notifications)

---

# 💡 Inspiration

Tudu is inspired by modern productivity applications such as **Todoist**, **TickTick**, and **Google Keep** while maintaining its own visual identity and implementation.

---

# 👨‍💻 Developer

**Alfred M. Tamayo** — Design & Development

Tudu is designed, built, and maintained by Alfred M. Tamayo as a portfolio project, covering the full journey from UI/UX design and architecture to cross-platform release builds for Windows and Android.


# Tudu

> A modern cross-platform productivity app built with Flutter, designed to help users manage daily tasks and notes across Windows, Android, and the web — usable on iPhone, iPad, Mac, and Linux through the browser.

![Version](https://img.shields.io/badge/version-v1.1.2-008080)
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

# ✨ What's New in v1.1.2

- 🎨 **Settings UI Consolidation**: Merged redundant "App Updates" and "About" sections into a unified **About & Updates** card with zero duplicate version labels.
- 📦 **Package Upgrade**: Replaced legacy file openers with `open_filex` for smoother cross-platform package launch and Android APK updates.
- 📲 **In-App Direct Update Installer** *(from v1.1.1)*: Automatically download and launch release updates (Android `.apk` or Windows `.zip`) directly within the app.
- 📱 **Android Home Screen Widgets** *(from v1.1.0)*: Track today's tasks straight from your Android device home screen.
- ⏰ **Task Start/End Time Ranges & Reminders** *(from v1.1.0)*: Set specific time ranges with scheduled 30-minute advance notifications and exact start-time alerts.
- ☀️🌙 **Sun-to-Moon Animated Transition** *(from v1.1.0)*: Dynamic app bar header animation that transforms between day and night.

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

# 🚀 Features

### 📋 Tasks
- Create, edit, search, and delete tasks
- Task start & end time ranges (e.g. 09:00 AM - 10:30 AM)
- Scheduled notifications (30-minute advance alert & exact start alert)
- Today view and overdue task tracking
- Categories & custom color-coded labels
- Priority levels & due dates

### 📝 Notes
- Create, edit, and organize notes
- Interactive checklists
- Instant note search
- Pin important notes to the top

### 📲 Android Home Screen Widgets
- Quick view of today's tasks directly on your Android home screen

### 🎨 User Experience
- Dynamic Sun ☀️ to Moon 🌙 animated transition reflecting day and night
- Cozy minimal Material 3 design
- Light & dark themes (with system auto preference)
- Task completion sound effects (`audioplayers`)
- Smooth page transitions and micro-animations

### 🔔 Notifications & In-App Updates
- Local notifications (`flutter_local_notifications`) for task reminders
- Configurable daily reminder notifications
- In-App GitHub update checker with direct APK/ZIP download and auto-installation launch (`open_filex`)

### ⚙️ Settings
- Unified **About & Updates** card with update status, developer info, and startup preferences
- Category manager sheet for custom category creation and palette management
- Backup & restore simulation (JSON data file handler)
- Sound effect and theme customization controls

---

# 🏗️ Architecture

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

# 🛠️ Tech Stack

- **Flutter** & **Dart**
- **Material 3** UI Framework
- **Provider** for State Management
- **Hive** & **SQLite** for Local Persistence
- **flutter_local_notifications** for Reminders
- **audioplayers** for Sound Effects
- **open_filex** & **url_launcher** for Updates & File Launching
- **Git** & **GitHub Actions / GitHub Pages**

---

# 🧪 Run Locally

### Windows

```powershell
flutter pub get
flutter build windows --release
```

### Android / mobile

```powershell
flutter pub get
flutter run

# Build lightweight Release APK (~18 MB):
flutter build apk --split-per-abi
```

> For Windows builds, make sure Visual Studio Build Tools with the Desktop development with C++ workload are installed.

---

# 📅 Roadmap

- [x] Project planning & setup
- [x] Task management & Notes management
- [x] Categories, labels & search functionality
- [x] Today view & overdue tracking
- [x] Due dates & start/end time ranges
- [x] Sun-to-Moon animated day/night header transitions
- [x] Scheduled start time reminders (30-min advance & start-time alerts)
- [x] In-app GitHub release update checker & direct update downloader/installer
- [x] Android Home Screen Widgets
- [x] Consolidated Settings UI & Version Management
- [x] Release v1.1.2

### 🎯 Next Version (v1.2.0) — Milestones

- [ ] **Backup & Restore to the Cloud** — Google Drive integration for cross-device sync
- [ ] Export & import data as a local file (JSON) for offline backup
- [ ] Recurring tasks (Daily, Weekly, Monthly)
- [ ] Calendar view for scheduled tasks
- [ ] Rich text editor support for notes

---

# 💡 Inspiration

Tudu is inspired by modern productivity applications such as **Todoist**, **TickTick**, and **Google Keep** while maintaining its own cozy visual identity and architecture.

---

# 👨‍💻 Developer

**Alfred M. Tamayo** — Design & Development

Tudu is designed, built, and maintained by Alfred M. Tamayo as a portfolio project, covering the full journey from UI/UX design and architecture to cross-platform release builds for Windows, Android, and Web.

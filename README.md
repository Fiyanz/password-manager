<div align="center">
  <img src="assets/IconBackgroundRemoved.png" alt="PassGuard Logo" width="150">
  <h1>PassGuard</h1>
  <p><strong>Secure. Simple. Offline.</strong></p>
</div>

**PassGuard** is a secure, offline-first password manager built with Flutter. It allows you to store, manage, and autofill your credentials seamlessly across Android apps and websites without relying on cloud services.

## ✨ Key Features

-   **Secure Storage**: All your passwords are stored locally on your device using SQLite.
-   **Android Autofill Service**: Automatically fill usernames and passwords in other apps and browsers (Requires Android 8.0+, optimized for Android 10+).
-   **Smart Management**:
    -   Categorize accounts (Social, Work, Finance, etc.).
    -   Search by name, username, or URL.
    -   Dynamic category filtering.
-   **Quick Actions**:
    -   One-tap copy for usernames and passwords.
    -   Direct URL launcher from details page.
-   **Modern UI**: Clean, intuitive interface with a focus on usability.

##  App Flow

1.  **Splash Screen**: Upon opening, you are greeted with a secure, animated splash screen.
2.  **Home Dashboard**:
    -   View all your saved passwords at a glance.
    -   Filter by categories (All, Social, Work, etc.) or use the search bar.
    -   Tap a card to view details or long-press to copy credentials.
3.  **Add Password**:
    -   Tap the floating action button (+) to save new credentials.
    -   Input Title, Username, Password, URL, and Category.
4.  **Autofill (The Magic)**:
    -   When logging into another app (e.g., Instagram), tap the username field.
    -   Select "Autofill with PassGuard".
    -   Unlock PassGuard (if biometric is enabled in future) and select the account.
    -   Credentials are automatically filled!

## 🚀 Getting Started

### Prerequisites
-   Flutter SDK
-   Android Studio / VS Code
-   Android Device/Emulator (API 29+ recommended for Autofill)

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/pass_manager.git
    cd pass_manager
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    flutter run
    ```

4.  **Build for Release:**
    ```bash
    flutter build apk --release
    ```

## 🤖 Enabling Autofill Service

To use the Autofill feature on your Android device:

1.  Open **Settings** on your phone.
2.  Go to **Passwords & Accounts** (or *System > Languages & Input > Autofill Service*).
3.  Tap on **Autofill service**.
4.  Select **PassGuard Autofill** from the list.
5.  Confirm by tapping **OK**.

## 🛠️ Tech Stack

-   **Framework**: [Flutter](https://flutter.dev/)
-   **Language**: Dart
-   **Database**: [sqflite](https://pub.dev/packages/sqflite) (SQLite)
-   **State Management**: [Provider](https://pub.dev/packages/provider)
-   **Autofill**: [flutter_autofill_service](https://pub.dev/packages/flutter_autofill_service)
-   **Launcher Icons**: [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)

## Future Roadmap

We are constantly working to improve PassGuard. Here are some exciting features coming soon:

-   [ ] **Cloud Sync**: Securely sync your passwords across devices using Google Drive or Dropbox.
-   [ ] **Database Encryption**: Enhanced security with AES-256 encryption for the SQLite database.
-   [ ] **Biometric Authentication**: Unlock the app using Fingerprint or Face ID.
-   [ ] **Import/Export**: Easily migrate your data from other password managers (CSV/JSON support).
-   [ ] **Desktop Support**: Native applications for Windows, macOS, and Linux.

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

# Flutter Expense Tracker

A modern, cross-platform expense tracker app built with Flutter. Features a bold yellow/black/white theme, Google Sign-In, persistent local storage, and a beautiful onboarding experience.

## Features

- **Multi-page Landing/Onboarding:**
  - Modern, multi-slide landing page with app logo and feature images.
  - Shown only on first launch (optional: can be configured).

- **Authentication:**
  - Google Sign-In and Sign-Up (with Firebase Auth).
  - Local username/password login and registration.
  - Seamless auto-login if already authenticated with Google.

- **Persistent Storage:**
  - User, expense, and fixed charge data stored locally using SQLite.
  - Data persists across app restarts.

- **Expense Management:**
  - Add, edit, and delete expenses with categories.
  - Visualize expenses and fixed charges with modern charts and UI.
  - Manage recurring (fixed) charges.

- **Modern UI:**
  - Bold yellow/black/white color scheme throughout.
  - Custom app logo as launcher icon and web favicon.
  - Responsive, attractive design for all screens (login, signup, home, settings, onboarding).

- **Cross-Platform:**
  - Android, iOS, and Web support.

## Getting Started

1. **Clone the repository:**
   ```sh
   git clone <your-repo-url>
   cd flutter_application_1
   ```

2. **Install dependencies:**
   ```sh
   flutter pub get
   ```

3. **Set up Firebase:**
   - Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) to the respective platform folders.
   - Configure your Firebase project for Google Sign-In.

4. **Run the app:**
   ```sh
   flutter run
   ```

5. **(Optional) Generate launcher icons:**
   ```sh
   flutter pub run flutter_launcher_icons:main
   ```

## Assets
- All images and logos are in the `assets/` folder and registered in `pubspec.yaml`.
- App icon and favicon use `assets/logo.png`.

## Customization
- To change the color scheme, update the `kYellow`, `kBlack`, and `kWhite` values in your Dart files.
- To update onboarding images, replace the `assets/landing_*.png` files.

## Troubleshooting
- **Google Sign-In not working?**
  - Ensure Firebase is initialized and your SHA-1/SHA-256 keys are set in the Firebase console.
  - Make sure your `google-services.json` and `GoogleService-Info.plist` are correct.
  - The app uses FirebaseAuth as the source of truth for login state.

- **App icon not updating?**
  - Run the launcher icon generation command above and rebuild the app.

## License

This project is for educational/demo purposes. Replace this section with your license as needed.

# MyXen Mobile App - Quick Start Guide

## 🚀 Getting Started

This guide will help you get the MyXen Mobile App up and running on your development machine.

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Flutter SDK** (3.0.0 or higher)
- **Dart SDK** (comes with Flutter)
- **Android Studio** (for Android development)
  - Android SDK (API 26 or higher)
  - Android Emulator or physical device
- **Xcode** (for iOS development, macOS only)
  - iOS Simulator or physical device
- **Git**

## 🔧 Installation Steps

### 1. Clone the Repository

```bash
cd "/home/bikkhoto/MyXen Mobile Application"
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This will download all the required packages specified in `pubspec.yaml`.

### 3. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates code for Riverpod providers, Freezed models, and JSON serialization.

### 4. Verify Installation

```bash
flutter doctor
```

This command checks your environment and displays a report of the status of your Flutter installation.

## 🏃 Running the App

### On Android Emulator/Device

1. Start an Android emulator or connect a physical device
2. Run the app:

```bash
flutter run
```

### On iOS Simulator/Device (macOS only)

1. Start an iOS simulator or connect a physical device
2. Run the app:

```bash
flutter run
```

### Hot Reload

While the app is running, you can make changes to the code and press:

- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

## 🏗️ Building for Production

### Android APK

```bash
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

### iOS (macOS only)

```bash
flutter build ios --release
```

Then open `ios/Runner.xcworkspace` in Xcode to archive and upload to App Store.

## 🧪 Running Tests

### Run All Tests

```bash
flutter test
```

### Run Tests with Coverage

```bash
flutter test --coverage
```

### Run Specific Test File

```bash
flutter test test/unit/key_manager_test.dart
```

## 📱 App Features

### ✅ Implemented

- Splash screen with animations
- Onboarding flow (3 pages)
- Wallet creation with PIN setup
- Recovery phrase display and backup
- Wallet restoration from mnemonic
- Home screen with balance display
- Bottom navigation

### 🚧 In Progress

- Send/Receive transactions
- QR code scanning and generation
- Transaction history
- Biometric authentication
- Settings and profile management

## 🔐 Security Features

### Cryptography

- **BIP39** - 12-word mnemonic generation
- **ed25519** - Transaction signing
- **AES-256-GCM** - Seed encryption
- **scrypt** - PIN-based key derivation (N=16384, r=8, p=1)
- **Hardware Keystore** - Platform-specific secure storage

### Key Management

- On-device key generation
- Encrypted seed storage
- Memory zeroization
- No private keys leave the device

## 🎨 Design System

### Colors

- **Primary**: Indigo (#6366F1)
- **Secondary**: Purple (#8B5CF6)
- **Accent**: Cyan (#06B6D4)
- **Success**: Green (#10B981)
- **Error**: Red (#EF4444)
- **Warning**: Amber (#F59E0B)

### Spacing

- XS: 4px
- SM: 8px
- MD: 16px
- LG: 24px
- XL: 32px
- 2XL: 48px

### Typography

- Font Family: Inter
- Weights: Regular (400), Medium (500), SemiBold (600), Bold (700)

## 📂 Project Structure

```
lib/
├── core/
│   ├── crypto/              # Cryptography modules
│   ├── theme/               # App theme
│   ├── network/             # API clients
│   └── storage/             # Local database
├── features/
│   ├── splash/              # Splash screen
│   ├── onboarding/          # Onboarding
│   ├── wallet/              # Wallet management
│   ├── home/                # Home screen
│   ├── send/                # Send transactions
│   ├── receive/             # Receive payments
│   ├── qr/                  # QR features
│   └── ...
├── providers/               # Riverpod providers
├── models/                  # Data models
├── widgets/                 # Reusable widgets
└── main.dart               # App entry point
```

## 🐛 Troubleshooting

### Issue: "Flutter command not found"

**Solution**: Add Flutter to your PATH:

```bash
export PATH="$PATH:`pwd`/flutter/bin"
```

### Issue: "Unable to locate Android SDK"

**Solution**: Set ANDROID_HOME environment variable:

```bash
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### Issue: "CocoaPods not installed" (iOS)

**Solution**: Install CocoaPods:

```bash
sudo gem install cocoapods
```

### Issue: "Gradle build failed"

**Solution**: Clean and rebuild:

```bash
flutter clean
flutter pub get
flutter run
```

## 📚 Useful Commands

```bash
# Check Flutter version
flutter --version

# List connected devices
flutter devices

# Analyze code
flutter analyze

# Format code
flutter format .

# Clean build artifacts
flutter clean

# Upgrade dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

## 🔗 Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Riverpod Documentation](https://riverpod.dev/)
- [Solana Documentation](https://docs.solana.com/)

## 💡 Development Tips

1. **Use Hot Reload**: Make changes and see them instantly without restarting
2. **Enable DevTools**: Use Flutter DevTools for debugging and performance profiling
3. **Follow Linting Rules**: The project uses strict linting rules for code quality
4. **Write Tests**: Add tests for new features before implementation
5. **Use Const Constructors**: Improves performance by reducing widget rebuilds

## 🤝 Contributing

1. Create a feature branch
2. Make your changes
3. Run tests and linting
4. Submit a pull request

## 📄 License

[Add License Information]

## 📞 Support

For support, please contact [support contact] or visit the Support Center in the app.

---

**Happy Coding! 🎉**

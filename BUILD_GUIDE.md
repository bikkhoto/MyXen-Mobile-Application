# 🚀 BUILD & RUN GUIDE - MyXen Mobile App

## ✅ **Prerequisites**

- Flutter SDK 3.16.0 or higher
- Dart SDK 3.2.0 or higher
- Android Studio / Xcode (for native builds)
- Android SDK (API 26+) / iOS 12+

---

## 📝 **Step 1: Install Dependencies**

```bash
cd "/home/bikkhoto/MyXen Mobile Application"
flutter pub get
```

---

## 🔧 **Step 2: Generate Code (REQUIRED)**

This generates Drift database code and Freezed models:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Expected output:**

- `lib/core/storage/database.g.dart`
- `lib/models/*.freezed.dart`
- `lib/models/*.g.dart`

---

## 🏗️ **Step 3: Build the App**

### **For Android:**

```bash
# Debug build
flutter build apk --debug

# Release build (for production)
flutter build apk --release

# Build location:
# build/app/outputs/flutter-apk/app-release.apk
```

### **For iOS:**

```bash
# Debug build
flutter build ios --debug

# Release build (requires Apple Developer account)
flutter build ios --release

# Build location:
# build/ios/iphoneos/Runner.app
```

---

## 🎯 **Step 4: Run the App**

### **On Emulator/Simulator:**

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode (hot reload enabled)
flutter run

# Run in release mode
flutter run --release
```

### **On Physical Device:**

1. **Android:**
   - Enable Developer Options
   - Enable USB Debugging
   - Connect device via USB
   - Run: `flutter run`

2. **iOS:**
   - Connect device
   - Trust computer
   - Run: `flutter run`

---

## 🧪 **Step 5: Testing**

### **Run All Tests:**

```bash
flutter test
```

### **Run Specific Test:**

```bash
flutter test test/unit/crypto_test.dart
```

### **Run with Coverage:**

```bash
flutter test --coverage
```

---

## 🔍 **Step 6: Verify Configuration**

Check that the app is properly configured:

```bash
# Check MYXN token is set
grep "myxnTokenMint" lib/core/network/api_config.dart

# Should show: 6S4eDdYXABgtmuk3waLM63U2KHgExcD9mco7MuyG9f5G
```

---

## 📱 **Step 7: First Run Checklist**

After building, verify these features work:

- [ ] App launches successfully
- [ ] Splash screen displays
- [ ] Onboarding flow works
- [ ] Can create new wallet
- [ ] Can restore wallet from mnemonic
- [ ] PIN setup works
- [ ] Biometric auth works (on device)
- [ ] Can view balance (devnet)
- [ ] QR scanner opens camera
- [ ] Can navigate all screens
- [ ] Settings screen accessible

---

## 🐛 **Troubleshooting**

### **Issue: Build fails with "No such file: database.g.dart"**

**Solution:**

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### **Issue: "Gradle build failed" (Android)**

**Solution:**

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk
```

### **Issue: "Pod install failed" (iOS)**

**Solution:**

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter build ios
```

### **Issue: Camera permission denied**

**Solution:**

- Android: Check `AndroidManifest.xml` has camera permission
- iOS: Check `Info.plist` has camera usage description

### **Issue: Biometric auth not working**

**Solution:**

- Ensure device has biometric hardware
- Check permissions in manifest/Info.plist
- Test on physical device (not emulator)

---

## 📦 **Build for Production**

### **Android (APK):**

```bash
# Build release APK
flutter build apk --release --split-per-abi

# Outputs:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM)
# - app-x86_64-release.apk (64-bit x86)
```

### **Android (App Bundle for Play Store):**

```bash
flutter build appbundle --release

# Output: build/app/outputs/bundle/release/app-release.aab
```

### **iOS (for App Store):**

```bash
flutter build ios --release

# Then open Xcode and archive:
open ios/Runner.xcworkspace
```

---

## 🔐 **Security Notes**

- ✅ Never commit `.env` file
- ✅ Never commit private keys
- ✅ Use ProGuard/R8 for Android release
- ✅ Enable code obfuscation for iOS
- ✅ Test on physical devices before release
- ✅ Run security audit before production

---

## 📊 **Performance Optimization**

### **Reduce APK Size:**

```bash
flutter build apk --release --split-per-abi --shrink
```

### **Enable Obfuscation:**

```bash
flutter build apk --release --obfuscate --split-debug-info=./debug-info
```

---

## 🎉 **Success!**

If you see the MyXen splash screen and can create a wallet, **you're ready to go!**

**Next steps:**

1. Test all features
2. Test on devnet
3. Security audit
4. Deploy to app stores

---

**Need help? Check:**

- `README.md` - Project overview
- `QUICK_START.md` - Quick setup guide
- `PROJECT_SUMMARY.md` - Implementation details

**Happy building! 🚀**

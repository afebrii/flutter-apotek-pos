# Panduan Instalasi Flutter Apotek App

Dokumentasi lengkap untuk instalasi Flutter, setup project, menjalankan aplikasi, dan build APK.

---

## Daftar Isi

1. [Persyaratan Sistem](#persyaratan-sistem)
2. [Instalasi Flutter di Windows](#instalasi-flutter-di-windows)
3. [Instalasi Flutter di macOS](#instalasi-flutter-di-macos)
4. [Clone & Setup Project](#clone--setup-project)
5. [Menjalankan Aplikasi](#menjalankan-aplikasi)
6. [Build APK untuk Production](#build-apk-untuk-production)
7. [Build App Bundle (AAB)](#build-app-bundle-aab)
8. [Troubleshooting](#troubleshooting)

---

## Persyaratan Sistem

### Minimum Requirements

| Platform | Requirement |
|----------|-------------|
| **Windows** | Windows 10 atau lebih baru (64-bit) |
| **macOS** | macOS 10.15 (Catalina) atau lebih baru |
| **Disk Space** | Minimal 2.8 GB (tidak termasuk IDE) |
| **Tools** | Git versi 2.x |
| **Flutter SDK** | 3.10.1 atau lebih baru |
| **Dart SDK** | 3.10.1 atau lebih baru (termasuk dalam Flutter) |

### Untuk Android Development

- Android Studio (versi terbaru)
- Android SDK
- Android SDK Command-line Tools
- Android SDK Build-Tools
- Android SDK Platform-Tools
- Android Emulator (opsional)

---

## Instalasi Flutter di Windows

### Step 1: Download Flutter SDK

1. Kunjungi [flutter.dev/docs/get-started/install/windows](https://flutter.dev/docs/get-started/install/windows)

2. Download Flutter SDK (file zip sekitar 1GB)

3. Extract ke folder yang diinginkan, contoh:
   ```
   C:\flutter
   ```

   > **Catatan:** Hindari path dengan spasi atau karakter khusus. Jangan install di `C:\Program Files\`

### Step 2: Setup Environment Variables

1. Buka **Start Menu** → cari **"Environment Variables"** → pilih **"Edit the system environment variables"**

2. Klik **"Environment Variables..."**

3. Di bagian **"User variables"**, cari variable **Path**, lalu klik **Edit**

4. Klik **New** dan tambahkan:
   ```
   C:\flutter\bin
   ```

5. Klik **OK** untuk semua dialog

### Step 3: Verifikasi Instalasi

Buka **Command Prompt** atau **PowerShell** baru, lalu jalankan:

```bash
flutter --version
```

Output yang diharapkan:
```
Flutter 3.x.x • channel stable
Framework • revision xxxxxxx
Engine • revision xxxxxxx
Tools • Dart 3.x.x
```

### Step 4: Install Android Studio

1. Download Android Studio dari [developer.android.com/studio](https://developer.android.com/studio)

2. Install dengan opsi default

3. Buka Android Studio → **More Actions** → **SDK Manager**

4. Di tab **SDK Platforms**, centang:
   - Android 14.0 (API 34) atau terbaru
   - Android 13.0 (API 33)

5. Di tab **SDK Tools**, centang:
   - Android SDK Build-Tools
   - Android SDK Command-line Tools
   - Android Emulator
   - Android SDK Platform-Tools

6. Klik **Apply** dan tunggu download selesai

### Step 5: Accept Android Licenses

```bash
flutter doctor --android-licenses
```

Tekan **y** untuk menyetujui semua lisensi.

### Step 6: Flutter Doctor

Jalankan untuk memastikan semua siap:

```bash
flutter doctor -v
```

Pastikan semua item menunjukkan ✓ (centang hijau), terutama:
- Flutter
- Android toolchain
- Android Studio

---

## Instalasi Flutter di macOS

### Step 1: Install Homebrew (Jika belum ada)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Step 2: Install Flutter via Homebrew

```bash
brew install --cask flutter
```

Atau download manual:

1. Kunjungi [flutter.dev/docs/get-started/install/macos](https://flutter.dev/docs/get-started/install/macos)

2. Download Flutter SDK untuk macOS

3. Extract ke folder yang diinginkan:
   ```bash
   cd ~/development
   unzip ~/Downloads/flutter_macos_x.x.x-stable.zip
   ```

### Step 3: Setup PATH (Jika install manual)

Tambahkan ke `~/.zshrc` atau `~/.bashrc`:

```bash
export PATH="$PATH:$HOME/development/flutter/bin"
```

Reload shell:
```bash
source ~/.zshrc
# atau
source ~/.bashrc
```

### Step 4: Verifikasi Instalasi

```bash
flutter --version
```

### Step 5: Install Xcode (Untuk iOS Development)

```bash
# Install Xcode dari App Store, atau:
xcode-select --install

# Setelah Xcode terinstall:
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

Accept Xcode license:
```bash
sudo xcodebuild -license accept
```

### Step 6: Install CocoaPods

```bash
sudo gem install cocoapods
```

Atau via Homebrew:
```bash
brew install cocoapods
```

### Step 7: Install Android Studio

1. Download dari [developer.android.com/studio](https://developer.android.com/studio)

2. Drag ke folder **Applications**

3. Buka dan ikuti wizard setup

4. Install SDK seperti pada panduan Windows di atas

### Step 8: Flutter Doctor

```bash
flutter doctor -v
```

Pastikan output menunjukkan:
```
[✓] Flutter
[✓] Android toolchain
[✓] Xcode
[✓] Android Studio
[✓] VS Code (opsional)
```

---

## Clone & Setup Project

### Step 1: Clone Repository

```bash
# Via HTTPS
git clone https://github.com/yourusername/flutter_apotek_app.git

# Atau via SSH
git clone git@github.com:yourusername/flutter_apotek_app.git
```

### Step 2: Masuk ke Direktori Project

```bash
cd flutter_apotek_app
```

### Step 3: Install Dependencies

```bash
flutter pub get
```

### Step 4: Generate Code (Freezed & JSON Serialization)

Project ini menggunakan `freezed` dan `json_serializable` untuk code generation:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Atau untuk watch mode (auto-generate saat file berubah):
```bash
dart run build_runner watch --delete-conflicting-outputs
```

### Step 5: Konfigurasi API Base URL

Edit file `lib/core/constants/variables.dart`:

```dart
class Variables {
  // Ganti dengan URL server Anda
  static const String baseUrl = 'https://your-server.com';
  // Atau untuk development lokal:
  // static const String baseUrl = 'http://192.168.1.100:8000';

  static const String apiBaseUrl = '$baseUrl/api/v1';
  // ... rest of the code
}
```

> **Catatan:** Untuk development di emulator Android, gunakan `10.0.2.2` untuk mengakses localhost komputer host.

---

## Menjalankan Aplikasi

### Cek Device yang Tersedia

```bash
flutter devices
```

Output contoh:
```
3 connected devices:

Pixel 7 (mobile)     • emulator-5554 • android-arm64 • Android 14
macOS (desktop)      • macos         • darwin-arm64  • macOS 14.0
Chrome (web)         • chrome        • web-javascript • Google Chrome
```

### Run di Android Emulator

1. Buka Android Studio → **Virtual Device Manager**
2. Create atau start emulator
3. Jalankan aplikasi:

```bash
flutter run
```

### Run di Physical Android Device

1. Aktifkan **Developer Options** di HP:
   - Buka **Settings** → **About Phone**
   - Tap **Build Number** 7 kali

2. Aktifkan **USB Debugging**:
   - **Settings** → **Developer Options** → **USB Debugging** → ON

3. Hubungkan HP via USB

4. Verifikasi device terdeteksi:
   ```bash
   flutter devices
   ```

5. Jalankan aplikasi:
   ```bash
   flutter run
   ```

### Run di iOS Simulator (macOS only)

```bash
# Buka iOS Simulator
open -a Simulator

# Jalankan aplikasi
flutter run
```

### Run di Physical iOS Device (macOS only)

1. Hubungkan iPhone/iPad via USB
2. Trust computer di device
3. Buka project di Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```
4. Setup signing di Xcode (pilih Team)
5. Jalankan dari terminal:
   ```bash
   flutter run
   ```

### Hot Reload & Hot Restart

Saat aplikasi berjalan:
- **Hot Reload:** Tekan `r` di terminal
- **Hot Restart:** Tekan `R` di terminal
- **Quit:** Tekan `q` di terminal

---

## Build APK untuk Production

### Build APK (Universal)

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build APK per ABI (Recommended untuk distribusi)

```bash
flutter build apk --split-per-abi --release
```

Output (3 file APK lebih kecil):
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk   # Untuk device ARM 32-bit
├── app-arm64-v8a-release.apk     # Untuk device ARM 64-bit (paling umum)
└── app-x86_64-release.apk        # Untuk emulator x86
```

> **Catatan:** `arm64-v8a` adalah yang paling umum digunakan untuk HP Android modern.

### Build dengan Obfuscation (Code Protection)

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

---

## Build App Bundle (AAB)

App Bundle adalah format yang direkomendasikan untuk upload ke Google Play Store:

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### Build AAB dengan Obfuscation

```bash
flutter build appbundle --release --obfuscate --split-debug-info=build/debug-info
```

---

## Signing APK untuk Production

### Step 1: Generate Keystore

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Anda akan diminta:
- Keystore password
- Key password (bisa sama dengan keystore password)
- Nama, organisasi, dll

> **PENTING:** Simpan file keystore dan password dengan aman! Jika hilang, Anda tidak bisa update app di Play Store.

### Step 2: Buat File key.properties

Buat file `android/key.properties`:

```properties
storePassword=<password yang Anda buat>
keyPassword=<password yang Anda buat>
keyAlias=upload
storeFile=<path ke keystore, contoh: /Users/username/upload-keystore.jks>
```

> **Catatan:** Jangan commit file ini ke Git! Tambahkan ke `.gitignore`

### Step 3: Update build.gradle

Edit `android/app/build.gradle.kts`:

```kotlin
// Di bagian atas file, sebelum plugins block
import java.util.Properties
import java.io.FileInputStream

val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

// ... plugins block ...

android {
    // ... existing config ...

    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            // ... other release config ...
        }
    }
}
```

### Step 4: Build Signed APK

```bash
flutter build apk --release
```

APK sekarang sudah signed dan siap untuk distribusi.

---

## Troubleshooting

### "flutter: command not found"

**Windows:**
- Pastikan path Flutter sudah ditambahkan ke Environment Variables
- Restart Command Prompt/PowerShell

**macOS:**
- Pastikan export PATH ada di `~/.zshrc` atau `~/.bashrc`
- Jalankan `source ~/.zshrc`

### Android licenses not accepted

```bash
flutter doctor --android-licenses
```

### Could not find bundled Java

Android Studio terbaru menggunakan bundled JDK. Set JAVA_HOME:

**macOS:**
```bash
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
```

**Windows:**
```
set JAVA_HOME=C:\Program Files\Android\Android Studio\jbr
```

### Gradle build failed

1. Clean project:
   ```bash
   flutter clean
   cd android
   ./gradlew clean  # macOS/Linux
   gradlew.bat clean  # Windows
   cd ..
   flutter pub get
   ```

2. Jika masih error, hapus cache Gradle:
   ```bash
   rm -rf ~/.gradle/caches  # macOS/Linux
   rmdir /s /q %USERPROFILE%\.gradle\caches  # Windows
   ```

### CocoaPods issues (macOS)

```bash
cd ios
rm -rf Pods Podfile.lock
pod cache clean --all
pod install --repo-update
cd ..
```

### Build runner not generating files

```bash
# Clean dan regenerate
dart run build_runner clean
dart run build_runner build --delete-conflicting-outputs
```

### "Unable to find git in your PATH"

Install Git:
- **Windows:** [git-scm.com](https://git-scm.com)
- **macOS:** `xcode-select --install` atau `brew install git`

---

## Quick Commands Reference

| Command | Description |
|---------|-------------|
| `flutter doctor` | Check environment setup |
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app in debug mode |
| `flutter run --release` | Run app in release mode |
| `flutter build apk` | Build release APK |
| `flutter build apk --split-per-abi` | Build APK per architecture |
| `flutter build appbundle` | Build App Bundle (AAB) |
| `flutter clean` | Clean build files |
| `flutter devices` | List available devices |
| `dart run build_runner build` | Generate code |

---

## Kontributor

Dibuat dengan ❤️ untuk event Apotek App Demo

---

*Dokumentasi ini terakhir diperbarui: Januari 2025*

# 🚀 Flutter Profile Setup System (DigitalOcean Space Integration)

This is a robust and secure profile setup system built with Flutter. It completely bypasses `firebase_storage` version conflict issues by implementing direct **HTTP PUT uploads** to **DigitalOcean Spaces** using **AWS Signature V4** encryption. It integrates seamlessly with Firebase Auth, Firestore, Hive, and Riverpod.

---

## 🗺️ System Architecture & Workflow

1. **User Registration & Verification:** Upon successful email verification, a default local asset path (`assets/default_avatar.png`) is initialized in both Firestore and local Hive cache.
2. **Profile Setup UI:** The app detects if the image path is a local asset or a network URL and renders the appropriate avatar view.
3. **Secure Upload:** When a user selects a new image, the app signs the HTTP request locally using AWS V4 specifications and streams the file directly to DigitalOcean Space.
4. **State Synchronization:** On a successful upload (`HTTP 200`), the fresh CDN URL is updated across Firestore, Hive, and the Riverpod auth state provider synchronously.

---

## 🛠️ Prerequisites & Setup

### 1. Project Dependencies
Ensure your `pubspec.yaml` has the required configurations and proper indentation:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.0
  flutter_dotenv: ^5.1.0
  crypto: ^3.0.3
  http: ^1.2.0
  intl: ^0.19.0
  hive: ^2.2.3
  image_picker: ^1.1.0

flutter:
  uses-material-design: true
  assets:
    - .env
    - assets/images/profile.png


2. Environment Variables (.env)

Create a .env file in the root directory of your project (same level as pubspec.yaml).
Code snippet

DO_SPACE_ACCESS_KEY=YOUR_ACTUAL_DIGITALOCEAN_ACCESS_KEY
DO_SPACE_SECRET_KEY=YOUR_ACTUAL_DIGITALOCEAN_SECRET_KEY

    ⚠️ CRITICAL SECURITY NOTE: Never commit your .env file to version control. Add it to your .gitignore:
    Plaintext

    # .gitignore
    .env


3. App Initialization

Initialize flutter_dotenv inside your main.dart before running the app:
Dart

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  // Initialize Firebase & Hive here...
  runApp(const ProviderScope(child: MyApp()));


⚙️ Core Technical Implementation
AWS V4 Canonical Request Signing & DotEnv Loading

Instead of relying on heavy third-party storage plugins that cause dependency hell (like mime version conflicts), the upload method loads raw secrets via environment variables and builds custom signature headers dynamically:
# 🛒 Flutter E-Commerce Application

A robust, feature-rich E-Commerce application built with **Flutter**, designed to showcase modern state management, local caching, secure cloud integrations, and clean feature-based architecture.

This project was built as an internship/learning project to master the Flutter ecosystem, specifically focusing on Riverpod, Firebase, Hive, and secure API integrations.

---

## ✨ Key Features

*   **🔐 User Authentication:** Seamless Login and Registration using Firebase Authentication.
*   **🛍️ Product Management:** Browse products, view detailed descriptions, and manage items.
*   **🛒 Shopping Cart:** Add, remove, and manage items in a local cart before checkout.
*   **❤️ Favorites System:** Save favorite products for later viewing.
*   **📦 Order History:** Track past orders and their statuses.
*   **📍 Address Management & Maps:** Set up delivery addresses using `google_maps_flutter` and geolocation.
*   **👤 Advanced Profile Setup:** 
    *   Bypasses typical `firebase_storage` conflicts by implementing **direct HTTP PUT uploads** to **DigitalOcean Spaces** using **AWS Signature V4** encryption.
    *   Dynamic avatar rendering (local assets vs network URLs).
*   **💾 Offline Caching:** Robust local storage using **Hive** to cache orders, addresses, cart, products, and auth state for a faster, offline-friendly experience.

---

## 🛠️ Tech Stack & Dependencies

*   **Framework:** [Flutter](https://flutter.dev/) (SDK >=3.0.0)
*   **State Management:** `flutter_riverpod` (v2.5.2)
*   **Backend & DB:** `firebase_core`, `firebase_auth`, `cloud_firestore`
*   **Local Storage:** `hive`, `hive_flutter`, `shared_preferences`
*   **Networking:** `http`, `dio`, `pretty_dio_logger`, `internet_connection_checker_plus`
*   **Location Services:** `google_maps_flutter`, `geocoding`, `geolocator`
*   **Routing:** Standard Navigator 1.0 (with `go_router` available for future migration)
*   **UI/UX Utilities:** `shimmer`, `cached_network_image`, `cupertino_icons`
*   **Security & Utils:** `crypto`, `flutter_dotenv`, `jwt_decoder`, `intl`

---

## 📂 Project Architecture

The project follows a **Feature-Driven Directory Structure** to keep the codebase modular, scalable, and easy to maintain.

```text
lib/
 ├── core/              # Global constants, themes, and core configurations
 ├── features/          # Independent, fully-contained feature modules
 │    ├── auth/         # Login, Register, Splash Screen, Auth Models
 │    ├── cart/         # Cart management
 │    ├── favorites/    # User favorites
 │    ├── navigation/   # Bottom Navigation Bar setup
 │    ├── orders/       # Order history
 │    ├── products/     # Product listing and details
 │    └── profile/      # Profile setup, Edit Profile, Map Address setup
 ├── utils/             # Helper functions, formatting, and generic utilities
 └── main.dart          # Entry point, Firebase/Hive initialization, Route definitions
```

---

## 🚀 Getting Started

### 1. Prerequisites

Ensure you have the following installed:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.0.0 or higher)
*   Dart SDK
*   An IDE like VS Code or Android Studio.

### 2. Clone the Repository
```bash
git clone <your-repository-url>
cd riverpod_test/riverpod_test
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Code Generation (Hive Adapters)
Since the app uses Hive for local caching with custom models, you may need to generate the adapters:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 5. Environment Variables (`.env`)
The app uses DigitalOcean Spaces for profile image uploads. You must create a `.env` file in the root directory (same level as `pubspec.yaml`):

```env
DO_SPACE_ACCESS_KEY=your_digitalocean_access_key
DO_SPACE_SECRET_KEY=your_digitalocean_secret_key
```
> ⚠️ **CRITICAL SECURITY NOTE:** Never commit your `.env` file to version control. It is already included in `.gitignore`.

### 6. Firebase Configuration
Ensure your Firebase project is set up. You will need to add your `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) to their respective directories, or configure Firebase via the FlutterFire CLI.

### 7. Run the App
```bash
flutter run
```

---

## 🧠 AWS V4 Canonical Request Signing (Profile Uploads)

Instead of relying on heavy third-party storage plugins that sometimes cause dependency hell, this app features a custom upload method. It loads raw secrets via environment variables and builds custom signature headers dynamically to stream files directly to a DigitalOcean Space. On success (`HTTP 200`), the CDN URL is synced across Firestore, Hive, and Riverpod simultaneously.

---

## 🤝 Next Steps / Roadmap

As this project evolves, the following enhancements are planned:
1.  **Migration to `go_router`:** Moving from `Navigator 1.0` to `Navigator 2.0` for better deep-linking and automated authentication redirection.
2.  **Riverpod Code Generation:** Utilizing `riverpod_generator` for stricter type-safety and reduced boilerplate.
3.  **Repository Pattern Refactor:** Further decoupling Firebase and Hive calls from the UI into dedicated Repositories.
4.  **Unit & Widget Testing:** Increasing test coverage across models, providers, and core UI components.
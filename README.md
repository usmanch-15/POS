# 🛒 POS — Point of Sale App

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-Firestore-FFCA28?style=flat&logo=firebase&logoColor=black)
![GetX](https://img.shields.io/badge/State-GetX-8B00FF?style=flat)
![License](https://img.shields.io/badge/License-MIT-green?style=flat)
![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-blue?style=flat)

A powerful **Point of Sale (POS)** Flutter application built for retail businesses. Manage your shop's sales, billing, inventory, and customer records — all from one easy-to-use interface.

---

## 📸 Screenshots

> *(Add your screenshots here — Sales screen, Invoice screen, Inventory screen, Reports screen)*

| Sales Screen | Invoice | Inventory | Reports |
|---|---|---|---|
| ![](screenshots/sales.png) | ![](screenshots/invoice.png) | ![](screenshots/inventory.png) | ![](screenshots/reports.png) |

---

## 📱 About the App

POS is a modern, fast, and reliable Point of Sale solution designed for retail shops and businesses. It simplifies day-to-day operations with smart features like instant invoice generation, real-time stock tracking, and secure transaction management.

Whether you run a small shop or a multi-product store, POS helps you stay organized and in control.

---

## ✨ Key Features

- 🧾 **Fast Invoice Generation** — Create and print bills instantly
- 📦 **Inventory Management** — Track stock levels in real-time
- 📊 **Sales Reports** — View daily, weekly, and monthly sales summaries
- 👤 **Customer Records** — Maintain a complete customer database
- 🔒 **Secure Transactions** — Safe and reliable payment management
- ☁️ **Cloud Sync** — Data synced in real-time via Firebase Firestore
- 🖥️ **Simple Interface** — Clean, intuitive UI for quick operations

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | GetX |
| Backend / Database | Firebase Firestore |
| Authentication | Firebase Auth |
| UI | Custom Widgets, Material Design |
| Platform | Android, iOS |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (latest stable) — [Install Flutter](https://docs.flutter.dev/get-started/install)
- A Firebase project — [Firebase Console](https://console.firebase.google.com/)
- Android Studio or VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/usmanch-15/POS.git

# Navigate to project folder
cd POS

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Firebase Setup

1. Create a project at [Firebase Console](https://console.firebase.google.com/)
2. Add your Android/iOS app and download `google-services.json`
3. Place `google-services.json` inside `android/app/`
4. Enable **Firestore** and **Authentication** in Firebase Console

---

## 🏗️ Build

```bash
# Build APK (Android)
flutter build apk --release

# Build for iOS
flutter build ios --release
```

---

## 📂 Project Structure

```
lib/
├── main.dart               # App entry point
├── screens/                # UI screens (Sales, Inventory, Reports, etc.)
├── models/                 # Data models
├── controllers/            # GetX controllers (state management)
├── services/               # Firebase & business logic services
├── widgets/                # Reusable UI components
└── utils/                  # Helpers & constants
```

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first.

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add your feature'`
4. Push to the branch: `git push origin feature/your-feature`
5. Open a Pull Request

---

## 👨‍💻 Developer

**Muhammad Usman**
Flutter Developer | [GitHub](https://github.com/usmanch-15) | [Upwork](https://www.upwork.com/freelancers/~010e8c29f24c9207c6)

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

*Built with ❤️ using Flutter & Firebase*

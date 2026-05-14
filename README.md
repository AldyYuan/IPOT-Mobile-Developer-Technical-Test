# IPOT — In-Person Ordering Tool

A Flutter mobile app that lets restaurant guests scan a QR code on their table, browse the menu, build a cart, and track their order in real time — all without a waiter.

> **No live API** was provided in the spec. All network calls are handled by mock repositories that simulate realistic latency and responses. To connect a real backend, set `API_BASE_URL` in `.env` (see [Configuration](#configuration)).

**[Download latest APK](https://github.com/AldyYuan/IPOT-Mobile-Developer-Technical-Test/releases/latest)**

---

## Table of Contents

- [Features](#features)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Prerequisites](#prerequisites)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Building a Release](#building-a-release)
- [Tests](#tests)

---

## Features

| Screen | Description |
|---|---|
| **Scanner** | Scans a table QR code via the device camera |
| **Menu** | Browses items by category, supports search and customization options |
| **Cart** | Reviews selected items, adds a kitchen note, and places the order |
| **Order Tracking** | Polls order status and shows a live progress timeline |

---

## Architecture

The app follows a **feature-first, Provider-based** architecture.

```
lib/
├── core/               # Shared infrastructure
│   ├── api/            # Dio client, interceptors, endpoint constants
│   ├── models/         # Pure data classes (MenuItem, CartItem, OrderStatus…)
│   └── utils/
├── features/           # One folder per screen/domain
│   ├── scanner/        #   ScannerProvider + ScannerScreen
│   ├── menu/           #   MenuProvider + MenuRepository + MenuScreen
│   ├── cart/           #   CartProvider + CartScreen
│   └── order/          #   OrderProvider + OrderRepository + OrderTrackingScreen
└── shared/
    ├── theme/          # AppColors, AppButtonTheme, TextFieldTheme
    └── widgets/
```

### Key decisions

- **Provider (`ChangeNotifier`)** — lightweight state management; one provider per feature domain.
- **Repository pattern** — each feature owns a repository class that owns all API calls. Swapping mock ↔ real backend only requires changing the repository implementation.
- **`flutter_dotenv`** — `API_BASE_URL` is read from `.env` at startup so the base URL is never hard-coded in source.
- **Dio + interceptors** — `LoggingInterceptor` and `RetryInterceptor` are applied globally via `APIClient` singleton.
- **Named routes** — all navigation goes through `AppRoutes` constants; screens are decoupled from each other.

---

## Project Structure

```
ipot/
├── .env                  # ← you create this (see Configuration)
├── lib/
│   ├── main.dart
│   ├── app_routes.dart
│   ├── core/
│   └── features/
├── test/
│   ├── cart_provider_test.dart
│   └── order_provider_test.dart
├── android/
├── ios/
└── pubspec.yaml
```

---

## Prerequisites

| Tool | Version |
|---|---|
| Flutter | ≥ 3.29 |
| Dart | ≥ 3.7 |
| Xcode (iOS) | ≥ 15 |
| Android Studio / SDK | API 21+ |

Verify your setup:

```bash
flutter doctor
```

---

## Configuration

The app reads its API base URL from a `.env` file in the project root.

1. Copy the example file:

```bash
cp .env.example .env
```

2. Edit `.env`:

```env
API_BASE_URL=https://your-api-server.com
```

> **Note:** Because no live API was provided, the mock repositories ignore this value during development. The `APIClient` falls back to `https://api.ipot.dev` if the key is missing.

Create `.env.example` alongside this README to commit a safe template:

```env
# Base URL for the IPOT REST API
API_BASE_URL=https://api.ipot.dev
```

---

## Running the App

```bash
# 1. Install dependencies
flutter pub get

# 2. Run on a connected device or simulator
flutter run
```

To target a specific platform explicitly:

```bash
flutter run -d android
flutter run -d ios
```

---

## Building a Release

### Android (APK)

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android (App Bundle — recommended for Play Store)

```bash
flutter build appbundle --release
```

### iOS (requires macOS + Xcode)

```bash
flutter build ios --release
# Then archive and distribute from Xcode
```

---

## Tests

Unit tests cover the two most critical pieces of business logic: **cart calculations** and **order state transitions**.

```bash
flutter test
```

### Test files

| File | What it covers |
|---|---|
| `test/cart_provider_test.dart` | Item add/merge, subtotal with option price modifiers, decrement-to-remove, `clear()` |
| `test/order_provider_test.dart` | `submitOrder` state transitions (initial → tracking), error handling, `reset()` |

**10 tests, 0 failures.**

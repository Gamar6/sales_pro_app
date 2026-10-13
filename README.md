# Fiva Sales App — Mobile

> Flutter-based mobile application for Fiva Food's field sales operations.

Fiva Sales App is a field sales application built with **Flutter** to support sales representatives in managing store visits, submitting visit reports, monitoring stock, accessing customer retention data, and performing sales-related activities.

The application communicates with the **Fiva Sales App Backend API** to authenticate users, retrieve operational data, submit store visits, upload reports, and synchronize field activities.

---

## Overview

The application is designed for field sales representatives who need to manage their daily activities directly from a mobile device.

The main workflow revolves around store visits:

```text
Login
  │
  ▼
Home
  │
  ├── Store Visit
  │     │
  │     ├── Select Store
  │     ├── Claim Store
  │     ├── Capture Location
  │     ├── Submit Visit Report
  │     └── Upload Photos
  │
  ├── Visit History
  │
  ├── Stock
  │
  ├── Store Retention
  │
  ├── Price Simulation
  │
  └── Profile
```

The application is backed by a Laravel REST API.

---

## Architecture

```text
┌─────────────────────────────────────┐
│          Fiva Sales App             │
│              Flutter                │
│                                     │
│  ┌──────────┐  ┌─────────────────┐  │
│  │   Auth   │  │   Home / Visit  │  │
│  └──────────┘  └─────────────────┘  │
│                                     │
│  ┌──────────┐  ┌─────────────────┐  │
│  │  Stock   │  │    Retention    │  │
│  └──────────┘  └─────────────────┘  │
│                                     │
│  ┌──────────┐  ┌─────────────────┐  │
│  │ Profile  │  │  Price Simulate │  │
│  └──────────┘  └─────────────────┘  │
└──────────────────┬──────────────────┘
                   │
                   │ REST API
                   ▼
┌─────────────────────────────────────┐
│       Fiva Sales App Backend        │
│              Laravel                │
│                                     │
│ Authentication                      │
│ Store Visits                        │
│ Visit Reports                       │
│ Stock                               │
│ Retention                           │
│ User Management                     │
└─────────────────────────────────────┘
                   │
                   ▼
              ┌──────────┐
              │   Odoo   │
              │   ERP    │
              └──────────┘
```

---

## Key Features

### 🔐 Authentication

The application provides a complete authentication flow for sales representatives.

Features include:

* Login
* Logout
* Forgot password
* Reset password
* Change password
* Session persistence
* Automatic authentication check on application startup

Authentication tokens are stored locally using `SharedPreferences`.

The application uses Bearer Token authentication when communicating with protected API endpoints.

---

### 🏠 Home

The Home screen acts as the main workspace for field sales representatives.

It provides access to the application's core sales workflows, including:

* Store visits
* Current active visit
* Visit reporting
* Visit history
* Stock information
* Retention data
* Price simulation
* User profile

The application also maintains the user's current visit state through the backend API.

---

### 🏪 Store Visit Management

Store visits are the primary workflow of the application.

Sales representatives can:

1. Select a store
2. Claim the store
3. Start an active visit
4. Capture visit information
5. Submit a visit report
6. Upload visit photos
7. Complete the visit
8. Cancel an active visit
9. View previous visits

The application communicates with the backend through dedicated visit services.

Example API workflow:

```text
GET  /api/visits/active
        │
        ▼
POST /api/store-visits/claim
        │
        ▼
POST /api/store-visits/{visit}/submit-report
        │
        ▼
GET  /api/store-visits/history
```

---

### 📍 GPS & Location

The application uses device location services during store visits.

Location functionality is handled through the dedicated location service and integrates with the backend's GPS validation system.

The application can retrieve:

* Latitude
* Longitude
* Location accuracy

This information is used as part of the store visit verification process.

The application also includes map functionality using Flutter map libraries and Google Maps integration.

---

### 📝 Visit Reports

After completing a store visit, sales representatives can submit a structured visit report.

Report information includes:

* PIC / contact person
* Activities
* Stock percentage
* Stock quantity
* Notes
* Visit photos

Photos are uploaded using multipart HTTP requests.

Example:

```text
Visit Report
│
├── PIC Name
├── Activities
├── Stock Percentage
├── Stock Quantity
├── Notes
└── Photos
     ├── Photo 1
     ├── Photo 2
     └── Photo N
```

---

### 📚 Visit History

Sales representatives can review their previous store visits.

The history screen provides information retrieved from:

```text
GET /api/store-visits/history
```

This allows users to review their completed or recorded visit activities.

---

### 📦 Stock Monitoring

The application provides a dedicated stock monitoring screen.

The stock service retrieves inventory information from the backend and displays:

* Total SKUs
* Low-stock count
* Product stock information

API:

```text
GET /api/stocks
```

The application also handles authentication expiration and API errors when retrieving stock information.

---

### 🔄 Store Retention

The application includes a dedicated customer/store retention workflow.

Retention data is retrieved from the backend through:

```text
GET /api/retensi
```

The application converts the API response into strongly typed `StoreModel` objects and sorts stores based on their configured priority.

This provides sales representatives with a structured view of stores that require attention.

---

### 💰 Price Simulation

The application includes a price simulation feature designed to assist sales representatives during field activities.

The feature is accessible through:

```text
lib/screens/sim_harga/
```

It provides a dedicated interface for performing sales-related price calculations and simulations.

---

### 👤 Profile Management

Sales representatives can manage their account information through the Profile screen.

Available functionality includes:

* View profile
* Change username
* Change password
* Upload profile photo
* Logout

Profile photos are uploaded to the backend using multipart requests.

---

### 🔗 Deep Linking

The application supports deep links for password reset flows.

The configured scheme is:

```text
fieldoperations://
```

Password reset links can contain:

```text
fieldoperations://reset-password
    ?token=<token>
    &email=<email>
```

When the application receives a valid reset-password deep link, it automatically navigates the user to the password reset screen.

This functionality is implemented using the `app_links` package.

---

## Tech Stack

### Core

| Technology      | Purpose                              |
| --------------- | ------------------------------------ |
| Flutter         | Cross-platform application framework |
| Dart            | Application programming language     |
| Material Design | UI framework                         |

### Networking & Authentication

| Package              | Purpose                     |
| -------------------- | --------------------------- |
| `http`               | REST API communication      |
| `shared_preferences` | Local session/token storage |

### Location & Maps

| Package               | Purpose                 |
| --------------------- | ----------------------- |
| `geolocator`          | Device GPS/location     |
| `flutter_map`         | Map visualization       |
| `latlong2`            | Geographic coordinates  |
| `google_maps_flutter` | Google Maps integration |

### Media

| Package        | Purpose                                 |
| -------------- | --------------------------------------- |
| `image_picker` | Capture/select visit and profile photos |

### Navigation & Utilities

| Package        | Purpose                    |
| -------------- | -------------------------- |
| `app_links`    | Deep link handling         |
| `url_launcher` | Launch external URLs       |
| `intl`         | Date and number formatting |

### Application Branding

| Package                  | Purpose                    |
| ------------------------ | -------------------------- |
| `flutter_native_splash`  | Application splash screen  |
| `flutter_launcher_icons` | Application launcher icons |

---

## Project Structure

```text
sales_pro_app/
│
├── android/
├── ios/
├── macos/
├── web/
├── windows/
│
├── assets/
│   └── images/
│
├── lib/
│   ├── main.dart
│   │
│   ├── models/
│   │   ├── contact_person.dart
│   │   ├── login_response.dart
│   │   ├── partner_model.dart
│   │   ├── status_style.dart
│   │   ├── stock_model.dart
│   │   ├── store_model.dart
│   │   └── visit_model.dart
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── forgot_password_screen.dart
│   │   │   └── reset_password_screen.dart
│   │   │
│   │   ├── home/
│   │   │   ├── home.dart
│   │   │   ├── detail_kunjungan_page.dart
│   │   │   ├── history_visit.dart
│   │   │   └── report.dart
│   │   │
│   │   ├── profile/
│   │   │   ├── profile_screen.dart
│   │   │   └── change_password_screen.dart
│   │   │
│   │   ├── retensi/
│   │   │   └── retensi_toko.dart
│   │   │
│   │   ├── sim_harga/
│   │   │   └── sim_harga.dart
│   │   │
│   │   └── stock/
│   │       └── stock_page.dart
│   │
│   ├── services/
│   │   ├── api_config.dart
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── location_service.dart
│   │   ├── stock_service.dart
│   │   ├── store_retention_service.dart
│   │   ├── store_visit_service.dart
│   │   └── visit_service.dart
│   │
│   ├── utils/
│   │   └── date_helper.dart
│   │
│   └── widgets/
│       ├── bottom_nav_widget.dart
│       └── home_header.dart
│
├── test/
│
├── pubspec.yaml
└── README.md
```

---

## API Integration

The application communicates with the Laravel backend through a centralized API configuration.

```text
lib/services/api_config.dart
```

The API client automatically attaches the stored authentication token to protected requests.

Example:

```http
Authorization: Bearer <token>
Accept: application/json
```

### Authentication

```text
POST /api/login
POST /api/forgot-password
POST /api/reset-password
POST /api/change-password
```

### Profile

```text
GET  /api/user
PUT  /api/user/username
POST /api/profile/photo
```

### Store Visits

```text
GET  /api/visits/active
POST /api/store-visits/claim
POST /api/store-visits/{visit}/submit-report
POST /api/store-visits/{visit}/cancel
GET  /api/store-visits/history
```

### Operational Data

```text
GET /api/stocks
GET /api/retensi
GET /api/contact-persons
```

The complete API implementation is maintained in the backend repository.

---

## Backend

This application is designed to work with the Fiva Sales App Laravel backend.

```text
Mobile App
    │
    │ REST API
    ▼
Laravel Backend
    │
    ├── MySQL
    ├── Odoo
    └── Cloudinary
```

Backend repository:

```text
https://github.com/Gamar6/api_sales_pro_app
```

---

## Installation

### Requirements

Make sure the development environment has:

* Flutter
* Dart SDK
* Android Studio / Android SDK for Android development
* Xcode for iOS/macOS development
* Git

Check the Flutter environment:

```bash
flutter doctor
```

---

### 1. Clone the repository

```bash
git clone https://github.com/Gamar6/sales_pro_app.git

cd sales_pro_app
```

---

### 2. Install dependencies

```bash
flutter pub get
```

---

### 3. Configure Backend API

The API base URL is configured in:

```text
lib/services/api_config.dart
```

Example:

```dart
class ApiConfig {
  static const String baseUrl =
      'http://your-server-address/api';
}
```

Replace the URL with the address of the Laravel backend environment.

For Android emulator development, the backend URL may need to use an address accessible from the emulator rather than `localhost`.

---

### 4. Run the application

Connect a device or start an emulator:

```bash
flutter devices
```

Then run:

```bash
flutter run
```

---

## Development Workflow

A typical development workflow is:

```bash
flutter pub get

flutter analyze

flutter test

flutter run
```

For Android development:

```bash
flutter run
```

For a specific connected device:

```bash
flutter devices
flutter run -d <device-id>
```

---

## Build

### Android APK

Build a release APK:

```bash
flutter build apk --release
```

The generated APK can be found under:

```text
build/app/outputs/flutter-apk/
```

For a smaller architecture-specific APK:

```bash
flutter build apk --split-per-abi
```

---

### Android App Bundle

For Google Play distribution:

```bash
flutter build appbundle --release
```

---

### Web

The repository also contains Flutter Web support.

Build:

```bash
flutter build web
```

---

### Windows

Build:

```bash
flutter build windows
```

---

### macOS

Build:

```bash
flutter build macos
```

---

### iOS

Build:

```bash
flutter build ios
```

iOS builds require macOS and Xcode.

---

## Testing

Run the Flutter test suite:

```bash
flutter test
```

Static analysis:

```bash
flutter analyze
```

The repository contains tests under:

```text
test/
```

and model-level tests under the application source where applicable.

---

## Session Management

Authentication state is maintained locally using `SharedPreferences`.

The application stores information such as:

```text
token
user_id
user_name
username
```

When the application starts, it checks whether a valid stored token exists.

```text
Application Start
       │
       ▼
Check Stored Token
       │
   ┌───┴───┐
   │       │
 Token    No Token
 Valid
   │       │
   ▼       ▼
 Home     Login
```

Logout removes the locally stored session information.

---

## Store Visit Flow

The complete field workflow can be represented as:

```text
┌─────────────────┐
│      Login      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│      Home       │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Select Store  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Claim Store   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Active Visit  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Capture Location│
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Fill Report    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Upload Photos   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Submit Report   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│     Done        │
└─────────────────┘
```

---

## Security Considerations

The application communicates with authenticated backend endpoints using Bearer tokens.

Sensitive configuration should not be committed to the repository.

In particular:

* Do not commit production API credentials.
* Do not hard-code production secrets.
* Do not expose authentication tokens.
* Use environment-specific API configuration for production deployments.
* Use HTTPS for production API communication.

> The repository may contain development-specific configuration. Review and replace local network addresses before distributing production builds.

---

## Supported Platforms

The Flutter project currently contains platform targets for:

| Platform | Project Support |
| -------- | --------------- |
| Android  | ✅               |
| iOS      | ✅               |
| Web      | ✅               |
| Windows  | ✅               |
| macOS    | ✅               |
| Linux    | Not configured  |

The primary target of the application is **Android mobile devices** for field sales operations.

---

## Project Status

Fiva Sales App is an internal field sales application developed for Fiva Food.

The current application provides:

* Authentication
* Password recovery
* Store visit management
* GPS/location integration
* Visit reporting
* Visit photo uploads
* Visit history
* Stock monitoring
* Store retention
* Price simulation
* Profile management
* Deep link password reset
* Laravel REST API integration

---

## Related Repository

### Backend & Admin Dashboard

```text
https://github.com/Gamar6/api_sales_pro_app
```

The backend repository contains:

* Laravel REST API
* Admin Dashboard
* Store visit business logic
* GPS/radius validation
* Odoo integration
* Cloudinary integration
* Reporting
* User management
* Excel exports

---

## Author

Developed and maintained by **Gamar6**.

Repository:

```text
https://github.com/Gamar6/sales_pro_app
```

---

## License

This project is currently maintained as an internal application.

Unless otherwise specified, the repository should not be considered an open-source project intended for redistribution or commercial reuse.

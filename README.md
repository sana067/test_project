# Stackbuffers Flutter Developer Hiring Task

A Flutter application demonstrating MVVM architecture, Provider state management, custom widgets, and API integration.

## 📋 Table of Contents

- [Architecture](#architecture)
- [Features](#features)
- [Project Structure](#project-structure)
- [How to Run](#how-to-run)
- [Assumptions](#assumptions)
- [Evaluation Criteria Coverage](#evaluation-criteria-coverage)

## 🏗️ Architecture

This project follows the **MVVM (Model-View-ViewModel)** architecture pattern with **Provider** for state management.

### Architecture Layers

1. **Models** (`lib/models/`)
   - Data classes representing API responses and requests
   - Pure Dart classes with JSON serialization/deserialization
   - Examples: `UserModel`, `LoginRequestModel`, `LoginResponseModel`, `UsersResponseModel`, `ApiResponse`

2. **Views** (`lib/views/`)
   - UI components (Screens)
   - Stateless/Stateful widgets that display data
   - Consume ViewModels using `Consumer` or `Provider.of`
   - Examples: `LoginScreen`, `DashboardScreen`

3. **ViewModels** (`lib/viewmodels/`)
   - Business logic and state management
   - Extend `ChangeNotifier` for Provider integration
   - Handle API calls through services
   - Notify listeners when state changes
   - Examples: `LoginViewModel`, `DashboardViewModel`

4. **Services** (`lib/services/`)
   - API communication layer
   - Handle HTTP requests and responses
   - Dynamic endpoint and parameter support
   - Example: `ApiService`

5. **Widgets** (`lib/widgets/`)
   - Reusable custom widgets
   - Examples: `CustomButton`, `CustomCard`, `CustomInputField`

### State Management Flow

```
View → ViewModel → Service → API
  ↑                    ↓
  └─── Provider ───────┘
```

- Views observe ViewModels using `Consumer` or `Provider.of`
- ViewModels use `notifyListeners()` to update UI
- State changes trigger automatic UI rebuilds

### Provider Implementation Details

**✅ Provider is used for state management:**
- `MultiProvider` setup in `main.dart` with `ChangeNotifierProvider` for each ViewModel
- `LoginViewModel` and `DashboardViewModel` extend `ChangeNotifier`
- Views use `Consumer<ViewModel>` widgets for reactive UI updates
- `notifyListeners()` called on all state changes (loading, success, error)
- State updates trigger automatic UI rebuilds without manual setState calls

## ✨ Features

### 1. Login Screen
- Email and password input fields with validation
- Form validation (email format, required fields, password length)
- Loading indicator in button during API call
- Success message on successful login
- Error message handling via SnackBar
- Real-time validation feedback
- Demo credentials displayed for testing

### 2. Dashboard Screen
- Dynamic user list fetched from API
- Pull-to-refresh functionality with success feedback
- Pagination support (Previous/Next buttons)
- Loading states with CircularProgressIndicator and text
- Error handling with retry option
- Success/error messages via SnackBar
- Custom user cards displaying avatar, name, email, and ID
- Page information display (current page, total pages, total users)

### 3. Custom Widgets
- **CustomButton**: Reusable button with loading state
- **CustomCard**: Consistent card styling with elevation
- **CustomInputField**: Text input with validation and icons

### 4. API Integration
- Dynamic API calls with configurable endpoints
- Support for query parameters
- API key authentication (`x-api-key: reqres-free-v1`)
- Proper error handling
- Loading, success, and error states
- Success and error messages via SnackBar

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point with Provider setup
├── models/                   # Data models
│   ├── user_model.dart
│   ├── login_request_model.dart
│   ├── login_response_model.dart
│   ├── users_response_model.dart
│   └── api_response_model.dart
├── views/                    # UI screens
│   ├── login_screen.dart
│   └── dashboard_screen.dart
├── viewmodels/               # Business logic & state
│   ├── login_viewmodel.dart
│   └── dashboard_viewmodel.dart
├── services/                 # API services
│   └── api_service.dart
└── widgets/                  # Reusable widgets
    ├── custom_button.dart
    ├── custom_card.dart
    └── custom_input_field.dart
```

## 🚀 How to Run

### Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- Android Emulator / iOS Simulator / Physical Device

### Steps

1. **Clone the repository** (if applicable)
   ```bash
   git clone <repository-url>
   cd test_project
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Testing the App

1. **Login Screen**
   - Use demo credentials:
     - Email: `eve.holt@reqres.in`
     - Password: `cityslicka`
   - Or test with invalid credentials to see error handling

2. **Dashboard Screen**
   - View list of users
   - Pull down to refresh
   - Use Previous/Next buttons for pagination
   - Test error handling by turning off internet

### Troubleshooting

#### "Missing API key" Error on Web

If you encounter a "Missing API key" error when running on Flutter web, this is likely due to:
- **CORS restrictions**: Some browsers/proxies may block cross-origin requests
- **Network configuration**: Firewall or proxy settings
- **API rate limiting**: The test API may have rate limits

**Solutions:**
1. **Run on mobile/desktop instead of web**: 
   ```bash
   flutter run -d chrome  # Try different device
   flutter run -d windows
   flutter run -d android
   ```

2. **Check browser console**: Open DevTools (F12) to see detailed error messages

3. **Try different network**: Test on a different network or disable VPN/proxy

4. **Clear browser cache**: Sometimes cached responses can cause issues

The app handles these errors gracefully and displays helpful error messages to guide users.

## 📝 Assumptions

1. **API Endpoints**: Using `https://reqres.in/api` as the test API
   - Login: `POST /api/login`
   - Users: `GET /api/users?page={page}`
   - **API Key**: All requests include `x-api-key: reqres-free-v1` header

2. **Authentication**: 
   - Token-based authentication (token stored in response, not persisted)
   - No token storage/refresh mechanism implemented (as per test requirements)

3. **Error Handling**:
   - Network errors shown via SnackBar
   - API errors displayed in UI with retry option
   - Form validation errors shown inline

4. **State Management**:
   - Using Provider package (as specified)
   - ViewModels are recreated on navigation (can be optimized with persistent providers if needed)

5. **UI/UX**:
   - Material Design 3
   - Responsive layout
   - Loading indicators for async operations
   - Professional and clean design

6. **Pagination**:
   - Page-based pagination (not infinite scroll)
   - Page numbers displayed in UI
   - Previous/Next navigation buttons

## ✅ Evaluation Criteria Coverage

### ✓ Correct use of Provider for state management
- ViewModels extend `ChangeNotifier`
- `MultiProvider` setup in `main.dart`
- `Consumer` widgets in Views for reactive updates
- `notifyListeners()` called on state changes

### ✓ Clear MVVM structure
- Separate folders for Models, Views, ViewModels
- Clear separation of concerns
- Views only handle UI, ViewModels handle business logic

### ✓ Clean, reusable custom widgets
- `CustomButton`, `CustomCard`, `CustomInputField`
- Consistent styling and behavior
- Easy to reuse across the app

### ✓ Proper handling of dynamic API calls
- `ApiService` with generic `getRequest` and `postRequest` methods
- Dynamic endpoint and parameter support
- Easy to change base URL or add new endpoints

### ✓ Error handling & loading state management
- `ApiResponse` model for state management
- Loading, success, and error states properly handled
- Loading indicators in buttons and screens
- SnackBar for success and error messages
- Retry functionality on errors
- Pull-to-refresh with success feedback

### ✓ Code readability & comments
- Clear variable and method names
- Comments explaining purpose of classes and methods
- Well-organized code structure
- Human-readable code style

## 🔧 Dependencies

- `flutter`: SDK
- `provider: ^6.1.1`: State management
- `http: ^1.2.0`: HTTP client for API calls
- `cupertino_icons: ^1.0.8`: iOS-style icons

## 📱 Screenshots

### Login Screen
- Email and password input fields
- Demo credentials hint
- Login button with loading state

### Dashboard Screen
- User list with avatars
- Pagination controls
- Pull-to-refresh
- Error handling UI

## 🎯 Feature Implementation Summary

### ✅ All Required Features Implemented

1. **✅ Loading Indicators**
   - Button loading state with CircularProgressIndicator in login screen
   - Full-screen loading indicator with text in dashboard
   - Loading state managed through Provider

2. **✅ Provider State Management**
   - Confirmed: Provider is used throughout the app
   - `MultiProvider` setup in `main.dart`
   - ViewModels extend `ChangeNotifier`
   - Views use `Consumer` widgets for reactive updates
   - `notifyListeners()` called on all state changes

3. **✅ API Response Handling**
   - **Loading State**: `ApiResponse.loading()` - Shows loading indicators
   - **Success State**: `ApiResponse.success(data)` - Displays data and success messages
   - **Error State**: `ApiResponse.error(message)` - Shows error messages with retry option
   - All states properly handled in both Login and Dashboard screens

4. **✅ Success/Error Messages**
   - Success message on login: "Login successful! Welcome back."
   - Success message on refresh: "Users refreshed successfully"
   - Error messages via SnackBar with red background
   - Error messages displayed in dashboard with retry button

5. **✅ Pull-to-Refresh Functionality**
   - Implemented in Dashboard screen using `RefreshIndicator`
   - Resets to page 1 on refresh
   - Shows success message after refresh

6. **✅ Form Validation**
   - Email format validation (regex pattern)
   - Required field validation
   - Password length validation (minimum 3 characters)
   - Real-time error display in input fields
   - Validation errors cleared when user types

7. **✅ Dynamic State Updates with Provider**
   - UI updates automatically when ViewModel state changes
   - No manual `setState` calls needed
   - Reactive UI using `Consumer` widgets

### 🎯 Extra Credit Features Implemented

1. ✅ **Professional UI**: Clean, modern Material Design 3 interface
2. ✅ **Pagination**: Full pagination support with Previous/Next buttons
3. ✅ **Error Recovery**: Retry functionality on API errors
4. ✅ **API Key Authentication**: All requests include `x-api-key` header
5. ✅ **Custom Widgets**: Reusable, well-designed custom components

## 📄 License

This project is created for Stackbuffers hiring task evaluation.

---

**Developed with ❤️ using Flutter**

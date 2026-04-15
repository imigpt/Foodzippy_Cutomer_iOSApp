# FoodZippy iOS - Customer App

## 🚀 Project Setup Guide

### Prerequisites
- macOS 13+ (Ventura or later)
- Xcode 15+
- iOS 16+ deployment target
- Apple Developer Account (for push notifications & signing)

### Step 1: Create Xcode Project

1. Open Xcode
2. **File → New → Project**
3. Choose **App** under iOS
4. Configure:
   - **Product Name:** FoodZippy
   - **Team:** Your Apple Developer Team
   - **Organization Identifier:** com.foodzippy
   - **Bundle Identifier:** com.foodzippy.customer
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Storage:** None
5. Save to: `/Users/tanayshrivastava/Desktop/Foodzippy iOS/foodzippy_customer_iosapp/`
6. **Delete** the auto-generated ContentView.swift, Assets.xcassets (we have our own)

### Step 2: Add Source Files

1. In Xcode, **right-click** the FoodZippy group → **Add Files to "FoodZippy"**
2. Navigate to the `FoodZippy/` folder and add all subfolders:
   - `App/` - Entry point, AppState, RootView
   - `Models/` - All data models
   - `ViewModels/` - MVVM ViewModels
   - `Views/` - All SwiftUI views (Auth, Home, Restaurant, Cart, Orders, Profile, Address, Search, Services, Utility)
   - `Services/` - APIService
   - `Utilities/` - SessionManager, CartManager, LocationManager, Extensions, Constants
3. Ensure "Copy items if needed" is **unchecked** (files are already in place)
4. Ensure "Create groups" is selected

### Step 3: Add Firebase

1. **File → Add Package Dependencies**
2. Enter: `https://github.com/firebase/firebase-ios-sdk.git`
3. Select version: **10.0.0** or later
4. Add these products:
   - ✅ FirebaseAuth
   - ✅ FirebaseMessaging
   - ✅ FirebaseDatabase
   - ✅ FirebaseAnalytics
   - ✅ FirebaseDynamicLinks
5. Copy your `GoogleService-Info.plist` from Firebase Console into the FoodZippy group

### Step 4: Configure Signing & Capabilities

1. Select the project in the navigator
2. Go to **Signing & Capabilities**
3. Set your **Team** and **Bundle Identifier** (`com.foodzippy.customer`)
4. Add capabilities:
   - **Push Notifications**
   - **Background Modes** → Remote notifications, Location updates, Background fetch
   - **Associated Domains** → `applinks:foodzippy.com`

### Step 5: Configure Info.plist

The `Info.plist` file is already created with all required permissions:
- Location (When In Use + Always)
- Camera
- Photo Library
- Microphone
- Contacts
- Push Notifications background modes
- URL Schemes (foodzippy://)
- App Transport Security

### Step 6: Build & Run

1. Select an iOS 16+ simulator or device
2. **Cmd + B** to build
3. **Cmd + R** to run

---

## 📁 Project Structure

```
FoodZippy/
├── App/
│   ├── FoodZippyApp.swift          # @main entry point, Firebase init, push setup
│   ├── AppState.swift              # Global observable state (screen, tab, cart badge)
│   └── RootView.swift              # Root navigation controller
│
├── Models/
│   ├── User.swift                  # User, LoginResponse, CountryCode, Profile
│   ├── Restaurant.swift            # Restaurant, RestaurantDetail, Reviews
│   ├── HomeModels.swift            # HomeData, Banners, Categories, Offers
│   ├── MenuItem.swift              # ProductCategory, MenuItem, Addons
│   ├── Order.swift                 # OrderHistory, OrderDetail, OrderLineItem
│   ├── Address.swift               # Address, AddressListResponse
│   ├── CartItem.swift              # CartItem with addon price calculation
│   ├── Payment.swift               # PaymentItem, Coupon, Wallet, Tip
│   └── Miscellaneous.swift         # FAQ, Help, Rating, Referral, Subscription, Refund
│
├── ViewModels/
│   ├── AuthViewModel.swift         # Login, Signup, OTP, ForgotPassword flows
│   ├── HomeViewModel.swift         # Home data, categories, filters, restaurants
│   ├── RestaurantViewModel.swift   # Restaurant detail, menu, gallery, reviews
│   ├── CartViewModel.swift         # Bill calculation, order placement
│   ├── ProfileViewModel.swift      # Profile, orders, wallet, favourites, logout
│   ├── OrderViewModel.swift        # Order detail, tracking, rating
│   └── SearchViewModel.swift       # Search with debounce, recent searches
│
├── Views/
│   ├── Auth/
│   │   ├── LoginView.swift         # Country code + phone login
│   │   ├── SignupView.swift        # Registration form
│   │   ├── OtpVerificationView.swift # 6-digit OTP with auto-focus
│   │   └── ForgotPasswordView.swift
│   │
│   ├── Splash/
│   │   └── SplashView.swift        # Animated logo splash
│   │
│   ├── Intro/
│   │   └── IntroView.swift         # 3-page onboarding
│   │
│   ├── Main/
│   │   └── MainTabView.swift       # 4-tab layout + cart overlay
│   │
│   ├── Home/
│   │   ├── HomeView.swift          # Full home screen (banners, categories, offers, restaurants)
│   │   ├── RestaurantRowView.swift # Restaurant list item card
│   │   └── RestaurantListView.swift # Generic restaurant list with filters
│   │
│   ├── Restaurant/
│   │   └── RestaurantDetailView.swift # Menu, addons, cart bar, gallery, reviews
│   │
│   ├── Search/
│   │   └── SearchView.swift        # Search with recent history + flow layout tags
│   │
│   ├── Cart/
│   │   └── CartView.swift          # Full cart: items, bill, payment, address, coupons, schedule
│   │
│   ├── Orders/
│   │   └── OrderDetailView.swift   # Order detail, tracking, rating, history
│   │
│   ├── Profile/
│   │   └── ProfileView.swift       # Profile hub, edit, privacy policy
│   │
│   ├── Address/
│   │   └── AddressListView.swift   # Address list + MapKit address picker
│   │
│   ├── Services/
│   │   └── ServiceViews.swift      # DineIn, Takeaway, DriveThru views
│   │
│   └── Utility/
│       ├── WalletView.swift        # Wallet balance + transactions
│       ├── FavouritesView.swift    # Favourite restaurants
│       ├── FaqView.swift           # FAQ accordion
│       ├── HelpView.swift          # Help & Support with contact options
│       ├── ReferralView.swift      # Refer & Earn with share
│       ├── RefundsView.swift       # Refund history
│       └── SubscriptionViews.swift # Plans + History
│
├── Services/
│   └── APIService.swift            # Actor-based networking (40+ endpoints)
│
├── Utilities/
│   ├── Constants.swift             # API paths, colors, keys
│   ├── SessionManager.swift        # UserDefaults persistence
│   ├── CartManager.swift           # Cart state (replaces SQLite)
│   ├── LocationManager.swift       # CoreLocation + geocoding
│   └── Extensions.swift            # Color, View, String, Image extensions
│
├── Assets.xcassets/
│   ├── AppIcon.appiconset/
│   └── AccentColor.colorset/
│
├── Info.plist                      # Permissions & configuration
└── GoogleService-Info.plist        # Firebase config (add from console)
```

---

## 🔄 Android → iOS Mapping

| Android | iOS |
|---------|-----|
| Java | Swift |
| XML Layouts | SwiftUI |
| Activities | Views (SwiftUI) |
| Fragments | Views (embedded) |
| RecyclerView | LazyVStack / List |
| SharedPreferences | UserDefaults (SessionManager) |
| SQLite (MyHelper) | UserDefaults (CartManager) |
| Retrofit + OkHttp | URLSession async/await (APIService) |
| Gson | Codable + JSONDecoder |
| Firebase Java SDK | Firebase iOS SDK |
| Google Maps | MapKit |
| FusedLocationProvider | CoreLocation |
| BottomSheetDialog | .sheet() |
| AlertDialog | .alert() / .confirmationDialog() |
| CoordinatorLayout | ScrollView with sticky headers |
| ViewPager2 | TabView(.page) |
| Intent extras | NavigationLink parameters |
| startActivityForResult | Callbacks / @Binding |

---

## 🔑 API Configuration

- **Base URL:** `https://zippy.truebasket.in/eapi/`
- **73+ endpoints** documented in `Constants.swift`
- **Authentication:** UID-based (sent as POST body parameter)
- All API calls use `multipart/form-data` POST

---

## 🎨 Design System

| Color | Hex | Usage |
|-------|-----|-------|
| Primary | #F72437 | Brand red, buttons, CTAs |
| Accent | #FC791A | Orange highlights, ratings |
| Green | #098430 | Success, veg indicator, cart |
| Red | #DD2020 | Error, non-veg, cancel |
| Black | #171A29 | Primary text |

---

## 📱 Features Implemented

- ✅ Splash screen with animation
- ✅ 3-page onboarding intro
- ✅ Phone login with OTP
- ✅ Sign up with referral
- ✅ Forgot password
- ✅ Home screen (banners, categories, offers, restaurants)
- ✅ Restaurant detail with collapsible header
- ✅ Menu with expandable categories
- ✅ Addon customization (single/multi select, sub-addons)
- ✅ Cart with full bill calculation
- ✅ Multiple payment methods
- ✅ Coupon system
- ✅ Tip selection
- ✅ Order scheduling
- ✅ Order tracking with polling
- ✅ Order rating with emojis
- ✅ Profile management
- ✅ Address management with MapKit
- ✅ Search with debounce + recent history
- ✅ Favourites
- ✅ Wallet
- ✅ Dine-in / Takeaway / Drive-thru
- ✅ Referral system
- ✅ FAQ & Help
- ✅ Subscription plans
- ✅ Refunds
- ✅ Veg/Non-veg filters
- ✅ Push notifications setup
- ✅ Deep linking URL scheme

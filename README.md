# Zomato Food Delivery App

A comprehensive iOS food delivery application built with SwiftUI, featuring modern UI design, Core Data persistence, REST API integration, and UIKit-SwiftUI bridging for favorites functionality.

## Features

### 🔐 Authentication
- **Login/Sign Up Screen**: User authentication with email and password
- **UserDefaults Integration**: Persistent login state management
- **Profile Management**: Edit user information and preferences
- **Secure Logout**: Proper session management

### 🏠 Home Screen
- **Food Categories**: Browse foods by category (Pizza, Burger, Pasta, etc.)
- **Search Functionality**: Search for specific foods
- **Popular Foods**: Featured items with ratings
- **Size Class Support**: Responsive design for different screen sizes
- **Modern UI**: Beautiful cards and smooth animations
- **Favorite Buttons**: Quick add/remove from favorites on food cards

### 🍕 Food Details
- **Detailed Information**: Complete food descriptions, nutrition info, and pricing
- **Add to Cart**: Quantity selection and cart integration
- **Image Loading**: Async image loading with placeholders
- **Food Tags**: Vegetarian, spicy, preparation time indicators
- **Favorite Integration**: Heart button to add/remove from favorites

### 🛒 Cart Management
- **Item Management**: Add, remove, and update quantities
- **Price Calculation**: Automatic subtotal, tax, and delivery fee calculation
- **Checkout Process**: Complete order placement flow
- **Order Confirmation**: Success feedback and order tracking

### 📦 Orders
- **Order History**: Complete order tracking and history
- **Status Tracking**: Real-time order status updates (Pending, Confirmed, Preparing, etc.)
- **Order Details**: Detailed view of each order with items and delivery info
- **Filter Options**: Filter orders by status
- **Statistics**: Order analytics and spending insights

### ❤️ Favorites (UIKit Integration)
- **UIKit View Controller**: Native iOS collection view for favorites
- **SwiftUI Bridge**: Seamless integration with SwiftUI app
- **Search & Filter**: Search favorites and filter by category
- **Add to Cart**: Direct add to cart from favorites
- **Remove Favorites**: Easy removal with confirmation
- **Empty State**: Beautiful empty state when no favorites
- **Statistics**: Favorites count and category breakdown

### 👤 Profile
- **User Information**: Display and edit user details
- **Order Statistics**: Total orders, spending, and average order value
- **Settings**: Account management and preferences
- **Logout**: Secure session termination

## Architecture

### Design Patterns
- **MVVM (Model-View-ViewModel)**: Clean separation of concerns
- **ObservableObject**: Reactive state management
- **EnvironmentObject**: Dependency injection
- **@Published**: Reactive property wrappers
- **UIKit-SwiftUI Bridge**: UIViewControllerRepresentable for favorites

### Data Management
- **Core Data**: Persistent storage for orders and user data
- **UserDefaults**: Lightweight data storage for authentication and favorites
- **REST API Integration**: TheMealDB API for food data
- **Error Handling**: Comprehensive error management

### Property Wrappers Used
- `@StateObject`: View model initialization
- `@EnvironmentObject`: Dependency injection
- `@Published`: Reactive state updates
- `@State`: Local view state
- `@ObservedObject`: Object observation

## Technical Implementation

### UIKit-SwiftUI Integration
- **FavoritesViewController**: Native UIKit collection view
- **UIViewControllerRepresentable**: SwiftUI wrapper for UIKit
- **FavoritesManager**: Singleton for favorites data management
- **NotificationCenter**: Real-time updates between UIKit and SwiftUI
- **UserDefaults**: Persistent favorites storage

### API Integration
- **TheMealDB API**: Open-source food database
- **GET Requests**: Fetch food categories and items
- **Error Handling**: Graceful fallback to mock data
- **Async/Await**: Modern concurrency patterns

### Core Data Entities
- **CDOrder**: Order information and relationships
- **CDOrderItem**: Individual food items in orders
- **CDUser**: User profile and authentication data

### Network Layer
- **NetworkService**: Centralized API management
- **HTTP Methods**: GET, POST, PUT, DELETE support
- **Error Types**: Custom error handling with enums
- **Mock Data**: Fallback data for development

### UI/UX Features
- **Size Classes**: Responsive design for iPhone and iPad
- **Dark Mode**: Automatic theme adaptation
- **Accessibility**: VoiceOver and accessibility support
- **Animations**: Smooth transitions and feedback

## File Structure

```
Zomato/
├── Models/
│   └── FoodModels.swift          # Data models and enums
├── Services/
│   ├── NetworkService.swift      # API communication
│   ├── UserDefaultsService.swift # Authentication storage
│   ├── CoreDataService.swift     # Core Data operations
│   └── FavoritesManager.swift    # Favorites data management
├── ViewModels/
│   ├── AppViewModel.swift        # Main app state
│   ├── FoodViewModel.swift       # Food data management
│   └── CartViewModel.swift       # Cart and order management
├── Views/
│   ├── Authentication/
│   │   └── LoginView.swift       # Login/signup screen
│   ├── Home/
│   │   └── HomeView.swift        # Main home screen
│   ├── Food/
│   │   └── FoodDetailView.swift  # Food details screen
│   ├── Cart/
│   │   └── CartView.swift        # Cart management
│   ├── Orders/
│   │   └── OrdersView.swift      # Order history
│   ├── Profile/
│   │   └── ProfileView.swift     # User profile
│   ├── Favorites/
│   │   ├── FavoritesViewController.swift # UIKit favorites view
│   │   ├── FavoritesView.swift   # SwiftUI wrapper
│   │   └── FavoritesIntegrationTest.swift # Integration testing
│   └── MainTabView.swift         # Tab navigation
├── CoreDataModels.swift          # Core Data extensions
└── ZomatoApp.swift              # Main app entry point
```

## Setup Instructions

1. **Clone the Repository**
   ```bash
   git clone <repository-url>
   cd Zomato
   ```

2. **Open in Xcode**
   - Open `Zomato.xcodeproj` in Xcode
   - Ensure you have Xcode 15.0+ installed

3. **Build and Run**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

4. **Testing**
   - Use the mock data for testing
   - Create an account or use existing credentials
   - Browse foods, add to favorites, and test the UIKit integration

## Dependencies

- **SwiftUI**: Modern declarative UI framework
- **UIKit**: Native iOS components for favorites
- **Core Data**: Persistent data storage
- **Foundation**: Basic iOS framework
- **TheMealDB API**: Free food database

## Features Implemented

✅ **Login/Sign Up Screen**  
✅ **Home Page with Food Categories**  
✅ **Food Detail View with Add to Cart**  
✅ **Cart Screen with Checkout**  
✅ **Order Management**  
✅ **Order Summary and History**  
✅ **Profile Screen**  
✅ **UserDefaults for Authentication**  
✅ **Open Source API Integration**  
✅ **Size Class Support**  
✅ **EnvironmentObject for Dependency Injection**  
✅ **All Property Wrappers (ObservableObject, @Published, etc.)**  
✅ **Core Data for Order Storage**  
✅ **User-Friendly Design**  
✅ **GET, POST, PUT, DELETE Support**  
✅ **Comprehensive Error Handling**  
✅ **Enum Usage Throughout**  
✅ **UIKit Favorites View Controller**  
✅ **SwiftUI-UIKit Bridge**  
✅ **Favorites Management System**  
✅ **Real-time Favorites Updates**  

## UIKit-SwiftUI Integration Details

### FavoritesViewController (UIKit)
- **UICollectionView**: Native iOS collection view for favorites
- **UISearchController**: Search functionality within favorites
- **Custom Cells**: FavoriteFoodCell with remove and add to cart buttons
- **Empty State**: Beautiful empty state when no favorites
- **Filter Options**: Filter favorites by category
- **Pull to Refresh**: Refresh favorites data

### SwiftUI Bridge
- **UIViewControllerRepresentable**: Wrapper for UIKit view controller
- **EnvironmentObject**: Pass SwiftUI data to UIKit
- **NotificationCenter**: Real-time updates between components
- **FavoritesManager**: Singleton for data management

### Key Integration Features
- **Seamless Navigation**: UIKit pushes SwiftUI views
- **Data Synchronization**: Real-time updates across components
- **Shared State**: Cart and user data shared between UIKit and SwiftUI
- **Consistent UI**: Matching design language across frameworks

## Screenshots

The app features a modern, intuitive interface with:
- Clean, card-based design
- Orange accent color scheme
- Smooth animations and transitions
- Responsive layout for different screen sizes
- Accessibility support
- UIKit favorites with native iOS feel

## Future Enhancements

- Push notifications for order updates
- Payment gateway integration
- Real-time order tracking
- Social media sharing
- Advanced search filters
- Restaurant ratings and reviews
- Favorites sync across devices
- Favorites sharing with friends

## License

This project is for educational purposes and demonstrates modern iOS development practices with SwiftUI, UIKit integration, and Core Data. 
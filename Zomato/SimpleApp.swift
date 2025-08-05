import SwiftUI

// MARK: - Simple Food Model
struct SimpleFood: Identifiable {
    let id = UUID()
    let name: String
    let price: Double
    let category: String
    let description: String
}

// MARK: - Simple App State
class SimpleAppState: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var cartItems: [SimpleFood] = []
    @Published var favorites: [SimpleFood] = []
    
    init() {
        // Check if user is logged in
        isLoggedIn = UserDefaults.standard.bool(forKey: "isLoggedIn")
    }
    
    func login(email: String, password: String) {
        if !email.isEmpty && !password.isEmpty {
            isLoggedIn = true
            UserDefaults.standard.set(true, forKey: "isLoggedIn")
            UserDefaults.standard.set(email, forKey: "userEmail")
            UserDefaults.standard.set("Test User", forKey: "userName")
        }
    }
    
    func logout() {
        isLoggedIn = false
        UserDefaults.standard.set(false, forKey: "isLoggedIn")
    }
    
    func addToCart(_ food: SimpleFood) {
        cartItems.append(food)
    }
    
    func addToFavorites(_ food: SimpleFood) {
        if !favorites.contains(where: { $0.id == food.id }) {
            favorites.append(food)
        }
    }
    
    func removeFromFavorites(_ food: SimpleFood) {
        favorites.removeAll { $0.id == food.id }
    }
}

// MARK: - Simple Content View
struct SimpleContentView: View {
    @StateObject private var appState = SimpleAppState()
    
    var body: some View {
        Group {
            if appState.isLoggedIn {
                SimpleMainTabView()
                    .environmentObject(appState)
            } else {
                SimpleLoginView()
                    .environmentObject(appState)
            }
        }
    }
}

// MARK: - Simple Login View
struct SimpleLoginView: View {
    @EnvironmentObject var appState: SimpleAppState
    @State private var email: String = ""
    @State private var password: String = ""
    
    var body: some View {
        VStack(spacing: 30) {
            // Logo
            VStack(spacing: 10) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("Zomato")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Delicious food delivered to your door")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            
            // Form
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Email")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    SecureField("Enter your password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Button(action: {
                    appState.login(email: email, password: password)
                }) {
                    Text("Sign In")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange)
                        .cornerRadius(10)
                }
                .disabled(email.isEmpty || password.isEmpty)
                .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.red.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
}

// MARK: - Simple Main Tab View
struct SimpleMainTabView: View {
    @EnvironmentObject var appState: SimpleAppState
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            SimpleHomeView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            SimpleFavoritesView()
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(1)
            
            SimpleCartView()
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                }
                .tag(2)
            
            SimpleOrdersView()
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("Orders")
                }
                .tag(3)
            
            SimpleProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.orange)
    }
}

// MARK: - Simple Home View
struct SimpleHomeView: View {
    @EnvironmentObject var appState: SimpleAppState
    
    private let mockFoods = [
        SimpleFood(name: "Margherita Pizza", price: 12.99, category: "Pizza", description: "Classic Italian pizza"),
        SimpleFood(name: "Chicken Burger", price: 9.99, category: "Burger", description: "Juicy chicken burger"),
        SimpleFood(name: "Spaghetti Carbonara", price: 14.99, category: "Pasta", description: "Traditional Italian pasta"),
        SimpleFood(name: "Caesar Salad", price: 8.99, category: "Salad", description: "Fresh romaine lettuce"),
        SimpleFood(name: "Chocolate Cake", price: 6.99, category: "Dessert", description: "Rich chocolate cake"),
        SimpleFood(name: "Iced Latte", price: 4.99, category: "Beverage", description: "Smooth espresso")
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Welcome to Zomato!")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                        ForEach(mockFoods) { food in
                            SimpleFoodCard(food: food)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle("Home")
        }
    }
}

// MARK: - Simple Food Card
struct SimpleFoodCard: View {
    let food: SimpleFood
    @EnvironmentObject var appState: SimpleAppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 120)
                .overlay(
                    Image(systemName: "photo")
                        .font(.system(size: 30))
                        .foregroundColor(.gray)
                )
                .cornerRadius(10)
            
            Text(food.name)
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
            
            Text(food.category)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack {
                Text("$\(String(format: "%.2f", food.price))")
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.orange)
                
                Spacer()
                
                Button(action: {
                    appState.addToFavorites(food)
                }) {
                    Image(systemName: "heart")
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Simple Favorites View
struct SimpleFavoritesView: View {
    @EnvironmentObject var appState: SimpleAppState
    
    var body: some View {
        NavigationView {
            Group {
                if appState.favorites.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "heart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("No Favorites Yet")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Start adding your favorite foods to see them here")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 15) {
                            ForEach(appState.favorites) { food in
                                SimpleFoodCard(food: food)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Favorites")
        }
    }
}

// MARK: - Simple Cart View
struct SimpleCartView: View {
    @EnvironmentObject var appState: SimpleAppState
    
    var body: some View {
        NavigationView {
            Group {
                if appState.cartItems.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "cart")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Your Cart is Empty")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add some delicious food to get started")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(appState.cartItems) { food in
                                HStack {
                                    Text(food.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Spacer()
                                    
                                    Text("$\(String(format: "%.2f", food.price))")
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Cart")
        }
    }
}

// MARK: - Simple Orders View
struct SimpleOrdersView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "bag")
                    .font(.system(size: 60))
                    .foregroundColor(.gray)
                
                Text("Orders")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your order history will appear here")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .navigationTitle("Orders")
        }
    }
}

// MARK: - Simple Profile View
struct SimpleProfileView: View {
    @EnvironmentObject var appState: SimpleAppState
    @State private var userName: String = UserDefaults.standard.string(forKey: "userName") ?? "Guest"
    @State private var userEmail: String = UserDefaults.standard.string(forKey: "userEmail") ?? ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text(userName)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(userEmail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Button("Logout") {
                    appState.logout()
                }
                .foregroundColor(.red)
                .padding()
            }
            .navigationTitle("Profile")
        }
    }
}

#Preview {
    SimpleContentView()
} 
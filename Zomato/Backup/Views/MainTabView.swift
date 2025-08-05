import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var foodViewModel: FoodViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Home Tab
            HomeView()
                .environmentObject(appViewModel)
                .environmentObject(foodViewModel)
                .environmentObject(cartViewModel)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Home")
                }
                .tag(0)
            
            // Favorites Tab
            FavoritesTabView()
                .environmentObject(cartViewModel)
                .environmentObject(appViewModel)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("Favorites")
                }
                .tag(1)
            
            // Cart Tab
            CartView()
                .environmentObject(cartViewModel)
                .environmentObject(appViewModel)
                .tabItem {
                    Image(systemName: "cart.fill")
                    Text("Cart")
                }
                .tag(2)
                .badge(cartViewModel.totalItems > 0 ? cartViewModel.totalItems : nil)
            
            // Orders Tab
            OrdersView()
                .environmentObject(cartViewModel)
                .tabItem {
                    Image(systemName: "bag.fill")
                    Text("Orders")
                }
                .tag(3)
            
            // Profile Tab
            ProfileView()
                .environmentObject(appViewModel)
                .environmentObject(cartViewModel)
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .accentColor(.orange)
        .onAppear {
            // Set tab bar appearance
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.systemBackground
            
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

#Preview {
    MainTabView()
} 
import SwiftUI
import UIKit

struct FavoritesView: UIViewControllerRepresentable {
    @EnvironmentObject var cartViewModel: CartViewModel
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let favoritesViewController = FavoritesViewController()
        let navigationController = UINavigationController(rootViewController: favoritesViewController)
        
        // Configure navigation controller
        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.navigationBar.tintColor = .systemOrange
        
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // Update the view controller if needed
    }
}

// MARK: - SwiftUI Integration
struct FavoritesTabView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    
    var body: some View {
        FavoritesView()
            .environmentObject(cartViewModel)
            .environmentObject(appViewModel)
    }
}

// MARK: - Favorites Button for Food Detail View
struct FavoriteButton: View {
    let food: Food
    @State private var isFavorite: Bool = false
    
    var body: some View {
        Button(action: {
            FavoritesManager.shared.toggleFavorite(food)
            isFavorite = FavoritesManager.shared.isFavorite(food)
        }) {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundColor(isFavorite ? .red : .gray)
        }
        .onAppear {
            isFavorite = FavoritesManager.shared.isFavorite(food)
        }
    }
}

// MARK: - Favorites Count Badge
struct FavoritesCountBadge: View {
    @State private var favoritesCount: Int = 0
    
    var body: some View {
        ZStack {
            Image(systemName: "heart.fill")
                .font(.title2)
                .foregroundColor(.red)
            
            if favoritesCount > 0 {
                Text("\(favoritesCount)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)
                    .background(Color.red)
                    .clipShape(Circle())
                    .offset(x: 8, y: -8)
            }
        }
        .onAppear {
            favoritesCount = FavoritesManager.shared.getFavoritesCount()
        }
        .onReceive(NotificationCenter.default.publisher(for: .favoritesUpdated)) { _ in
            favoritesCount = FavoritesManager.shared.getFavoritesCount()
        }
    }
}

// MARK: - Favorites Statistics View
struct FavoritesStatisticsView: View {
    @State private var statistics: [FoodCategory: Int] = [:]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Favorites Statistics")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                ForEach(FoodCategory.allCases, id: \.self) { category in
                    VStack(spacing: 8) {
                        Text(category.icon)
                            .font(.title2)
                        
                        Text("\(statistics[category] ?? 0)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(category.rawValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
            }
        }
        .onAppear {
            statistics = FavoritesManager.shared.getFavoritesStatistics()
        }
        .onReceive(NotificationCenter.default.publisher(for: .favoritesUpdated)) { _ in
            statistics = FavoritesManager.shared.getFavoritesStatistics()
        }
    }
}

// MARK: - Notification Extension
extension Notification.Name {
    static let favoritesUpdated = Notification.Name("favoritesUpdated")
}

// MARK: - FavoritesManager Extension
extension FavoritesManager {
    func notifyFavoritesUpdated() {
        NotificationCenter.default.post(name: .favoritesUpdated, object: nil)
    }
    
    func addToFavorites(_ food: Food) {
        var favorites = getFavorites()
        
        if !favorites.contains(where: { $0.id == food.id }) {
            favorites.append(food)
            saveFavorites(favorites)
            notifyFavoritesUpdated()
        }
    }
    
    func removeFromFavorites(_ food: Food) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == food.id }
        saveFavorites(favorites)
        notifyFavoritesUpdated()
    }
    
    func toggleFavorite(_ food: Food) {
        if isFavorite(food) {
            removeFromFavorites(food)
        } else {
            addToFavorites(food)
        }
    }
}

#Preview {
    FavoritesTabView()
        .environmentObject(CartViewModel())
        .environmentObject(AppViewModel())
} 

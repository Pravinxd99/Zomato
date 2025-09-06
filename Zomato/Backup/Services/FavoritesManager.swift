import Foundation

class FavoritesManager {
    static let shared = FavoritesManager()
    
    private let userDefaults = UserDefaults.standard
    private let favoritesKey = "userFavorites"
    private let ratingsKeys = "userRatings"
    
    private init() {}
    
    // MARK: - Favorites Management
    func getFavorites() -> [Food] {
        guard let data = userDefaults.data(forKey: favoritesKey),
              let favorites = try? JSONDecoder().decode([Food].self, from: data) else {
            return []
        }
        return favorites
    }
    
    func addToFavorites(_ food: Food) {
        var favorites = getFavorites()
        
        // Check if food is already in favorites
        if !favorites.contains(where: { $0.id == food.id }) {
            favorites.append(food)
            saveFavorites(favorites)
        }
    }
    
    func removeFromFavorites(_ food: Food) {
        var favorites = getFavorites()
        favorites.removeAll { $0.id == food.id }
        saveFavorites(favorites)
    }
    
    func isFavorite(_ food: Food) -> Bool {
        let favorites = getFavorites()
        return favorites.contains { $0.id == food.id }
    }
    
    func toggleFavorite(_ food: Food) {
        if isFavorite(food) {
            removeFromFavorites(food)
        } else {
            addToFavorites(food)
        }
    }
    
    func clearAllFavorites() {
        userDefaults.removeObject(forKey: favoritesKey)
    }
    
    // MARK: - Private Methods
    private func saveFavorites(_ favorites: [Food]) {
        if let data = try? JSONEncoder().encode(favorites) {
            userDefaults.set(data, forKey: favoritesKey)
        }
    }
    
    // MARK: - Statistics
    func getFavoritesCount() -> Int {
        return getFavorites().count
    }
    
    func getFavoritesByCategory(_ category: FoodCategory) -> [Food] {
        return getFavorites().filter { $0.category == category }
    }
    
    func getFavoritesStatistics() -> [FoodCategory: Int] {
        let favorites = getFavorites()
        var statistics: [FoodCategory: Int] = [:]
        
        for category in FoodCategory.allCases {
            statistics[category] = favorites.filter { $0.category == category }.count
        }
        
        return statistics
    }
} 

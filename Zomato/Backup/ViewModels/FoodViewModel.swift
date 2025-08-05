import Foundation
import SwiftUI

@MainActor
class FoodViewModel: ObservableObject {
    @Published var foods: [Food] = []
    @Published var filteredFoods: [Food] = []
    @Published var selectedCategory: FoodCategory?
    @Published var searchText: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let networkService = NetworkService.shared
    
    init() {
        loadFoods()
    }
    
    // MARK: - Data Loading
    func loadFoods() {
        Task {
            await fetchFoods()
        }
    }
    
    func fetchFoods() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Try to fetch from API first
            foods = try await networkService.fetchRandomMeals(count: 20)
            
            // If API fails, use mock data
            if foods.isEmpty {
                foods = networkService.getMockFoods()
            }
            
            applyFilters()
        } catch {
            // Use mock data if API fails
            foods = networkService.getMockFoods()
            errorMessage = "Failed to load from server. Using local data."
            showError = true
        }
        
        isLoading = false
    }
    
    func searchFoods(query: String) async {
        guard !query.isEmpty else {
            foods = networkService.getMockFoods()
            applyFilters()
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let searchResults = try await networkService.searchMeals(query: query)
            if !searchResults.isEmpty {
                foods = searchResults
            } else {
                // If no results, show all foods
                foods = networkService.getMockFoods()
            }
            applyFilters()
        } catch {
            foods = networkService.getMockFoods()
            errorMessage = "Search failed. Showing all items."
            showError = true
        }
        
        isLoading = false
    }
    
    func fetchFoodsByCategory(_ category: FoodCategory) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let categoryFoods = try await networkService.fetchMealsByCategory(category.rawValue)
            if !categoryFoods.isEmpty {
                foods = categoryFoods
            } else {
                // If no results, filter mock data by category
                foods = networkService.getMockFoods().filter { $0.category == category }
            }
            applyFilters()
        } catch {
            foods = networkService.getMockFoods().filter { $0.category == category }
            errorMessage = "Failed to load category. Using local data."
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Filtering
    func applyFilters() {
        var filtered = foods
        
        // Apply category filter
        if let category = selectedCategory {
            filtered = filtered.filter { $0.category == category }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            filtered = filtered.filter { food in
                food.name.localizedCaseInsensitiveContains(searchText) ||
                food.description.localizedCaseInsensitiveContains(searchText) ||
                food.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        filteredFoods = filtered
    }
    
    func filterByCategory(_ category: FoodCategory?) {
        selectedCategory = category
        applyFilters()
    }
    
    func clearFilters() {
        selectedCategory = nil
        searchText = ""
        applyFilters()
    }
    
    // MARK: - Search
    func performSearch() {
        Task {
            await searchFoods(query: searchText)
        }
    }
    
    // MARK: - Food Details
    func getFoodById(_ id: String) -> Food? {
        return foods.first { $0.id == id }
    }
    
    func getFoodsByCategory(_ category: FoodCategory) -> [Food] {
        return foods.filter { $0.category == category }
    }
    
    func getPopularFoods() -> [Food] {
        return foods.sorted { $0.rating > $1.rating }.prefix(5).map { $0 }
    }
    
    func getVegetarianFoods() -> [Food] {
        return foods.filter { $0.isVegetarian }
    }
    
    func getSpicyFoods() -> [Food] {
        return foods.filter { $0.isSpicy }
    }
    
    // MARK: - Error Handling
    func clearError() {
        errorMessage = nil
        showError = false
    }
    
    func showError(_ message: String) {
        errorMessage = message
        showError = true
    }
} 
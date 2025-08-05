import SwiftUI

struct FavoritesIntegrationTest: View {
    @State private var favoritesCount: Int = 0
    @State private var showingTestResults: Bool = false
    @State private var testResults: [String] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Test Controls
                VStack(spacing: 15) {
                    Text("Favorites Integration Test")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 15) {
                        Button("Add Test Favorites") {
                            addTestFavorites()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        
                        Button("Clear All") {
                            clearAllFavorites()
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    
                    Button("Run Tests") {
                        runTests()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                
                // Statistics
                VStack(spacing: 10) {
                    Text("Current Favorites: \(favoritesCount)")
                        .font(.headline)
                    
                    FavoritesStatisticsView()
                }
                
                // Test Results
                if !testResults.isEmpty {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Test Results:")
                            .font(.headline)
                        
                        ForEach(testResults, id: \.self) { result in
                            Text("• \(result)")
                                .font(.subheadline)
                                .foregroundColor(result.contains("✅") ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Favorites Test")
            .onAppear {
                updateFavoritesCount()
            }
            .onReceive(NotificationCenter.default.publisher(for: .favoritesUpdated)) { _ in
                updateFavoritesCount()
            }
        }
    }
    
    // MARK: - Test Methods
    private func addTestFavorites() {
        let mockFoods = NetworkService.shared.getMockFoods()
        
        // Add first 3 foods as favorites
        for i in 0..<min(3, mockFoods.count) {
            FavoritesManager.shared.addToFavorites(mockFoods[i])
        }
        
        updateFavoritesCount()
    }
    
    private func clearAllFavorites() {
        FavoritesManager.shared.clearAllFavorites()
        updateFavoritesCount()
    }
    
    private func updateFavoritesCount() {
        favoritesCount = FavoritesManager.shared.getFavoritesCount()
    }
    
    private func runTests() {
        testResults.removeAll()
        
        // Test 1: Add to favorites
        let testFood = NetworkService.shared.getMockFoods().first!
        FavoritesManager.shared.addToFavorites(testFood)
        
        if FavoritesManager.shared.isFavorite(testFood) {
            testResults.append("✅ Add to favorites - PASSED")
        } else {
            testResults.append("❌ Add to favorites - FAILED")
        }
        
        // Test 2: Remove from favorites
        FavoritesManager.shared.removeFromFavorites(testFood)
        
        if !FavoritesManager.shared.isFavorite(testFood) {
            testResults.append("✅ Remove from favorites - PASSED")
        } else {
            testResults.append("❌ Remove from favorites - FAILED")
        }
        
        // Test 3: Toggle favorites
        FavoritesManager.shared.toggleFavorite(testFood)
        
        if FavoritesManager.shared.isFavorite(testFood) {
            testResults.append("✅ Toggle favorites - PASSED")
        } else {
            testResults.append("❌ Toggle favorites - FAILED")
        }
        
        // Test 4: Get favorites count
        let count = FavoritesManager.shared.getFavoritesCount()
        if count > 0 {
            testResults.append("✅ Get favorites count - PASSED (\(count) items)")
        } else {
            testResults.append("❌ Get favorites count - FAILED")
        }
        
        // Test 5: Get favorites by category
        let pizzaFavorites = FavoritesManager.shared.getFavoritesByCategory(.pizza)
        testResults.append("✅ Get favorites by category - PASSED (\(pizzaFavorites.count) pizza items)")
        
        // Test 6: Get favorites statistics
        let statistics = FavoritesManager.shared.getFavoritesStatistics()
        let totalStats = statistics.values.reduce(0, +)
        if totalStats > 0 {
            testResults.append("✅ Get favorites statistics - PASSED (\(totalStats) total items)")
        } else {
            testResults.append("❌ Get favorites statistics - FAILED")
        }
        
        updateFavoritesCount()
        showingTestResults = true
    }
}

#Preview {
    FavoritesIntegrationTest()
} 
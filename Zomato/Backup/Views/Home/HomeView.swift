import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var foodViewModel: FoodViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var selectedTab: Int = 0
    @State private var showingFoodDetail: Food?
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerView
                    
                    // Search Bar
                    searchBar
                    
                    // Categories
                    categoriesView
                    
                    // Popular Foods
                    popularFoodsView
                    
                    // All Foods
                    allFoodsView
                }
                .padding(.horizontal, horizontalSizeClass == .compact ? 16 : 24)
            }
            .navigationBarHidden(true)
            .background(Color(.systemGroupedBackground))
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(item: $showingFoodDetail) { food in
            FoodDetailView(food: food)
                .environmentObject(cartViewModel)
        }
        .alert("Error", isPresented: $foodViewModel.showError) {
            Button("OK") {
                foodViewModel.clearError()
            }
        } message: {
            Text(foodViewModel.errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("Hello,")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text(appViewModel.currentUser?.name ?? "Guest")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            // Cart Button
            Button(action: {
                // Navigate to cart
            }) {
                ZStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "cart")
                        .font(.title2)
                        .foregroundColor(.white)
                    
                    if cartViewModel.totalItems > 0 {
                        Text("\(cartViewModel.totalItems)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .frame(width: 20, height: 20)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: 15, y: -15)
                    }
                }
            }
        }
        .padding(.top, 10)
    }
    
    // MARK: - Search Bar
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search for food...", text: $foodViewModel.searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .onSubmit {
                    foodViewModel.performSearch()
                }
            
            if !foodViewModel.searchText.isEmpty {
                Button("Clear") {
                    foodViewModel.searchText = ""
                    foodViewModel.clearFilters()
                }
                .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Categories View
    private var categoriesView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Categories")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    // All Categories Button
                    CategoryButton(
                        title: "All",
                        icon: "🍽️",
                        isSelected: foodViewModel.selectedCategory == nil
                    ) {
                        foodViewModel.filterByCategory(nil)
                    }
                    
                    // Category Buttons
                    ForEach(FoodCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: foodViewModel.selectedCategory == category
                        ) {
                            foodViewModel.filterByCategory(category)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - Popular Foods View
    private var popularFoodsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Popular Foods")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button("See All") {
                    // Navigate to all foods
                }
                .foregroundColor(.orange)
                .font(.subheadline)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(foodViewModel.getPopularFoods()) { food in
                        PopularFoodCard(food: food) {
                            showingFoodDetail = food
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - All Foods View
    private var allFoodsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("All Foods")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(foodViewModel.filteredFoods.count) items")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if foodViewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .scaleEffect(1.2)
                    Spacer()
                }
                .padding(.vertical, 50)
            } else if foodViewModel.filteredFoods.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                    
                    Text("No foods found")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                    
                    Text("Try adjusting your search or category filter")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 50)
            } else {
                LazyVGrid(
                    columns: Array(repeating: GridItem(.flexible(), spacing: 15), count: horizontalSizeClass == .compact ? 2 : 3),
                    spacing: 15
                ) {
                    ForEach(foodViewModel.filteredFoods) { food in
                        FoodCard(food: food) {
                            showingFoodDetail = food
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Category Button
struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(icon)
                    .font(.title2)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(width: 80, height: 80)
            .background(isSelected ? Color.orange : Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
    }
}

// MARK: - Popular Food Card
struct PopularFoodCard: View {
    let food: Food
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Food Image with Favorite Button
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: food.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(width: 150, height: 120)
                    .clipped()
                    .cornerRadius(15)
                    
                    // Favorite Button
                    FavoriteButton(food: food)
                        .padding(8)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .padding(8)
                }
                
                // Food Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    HStack {
                        Text("$\(String(format: "%.2f", food.price))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", food.rating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Food Card
struct FoodCard: View {
    let food: Food
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Food Image with Favorite Button
                ZStack(alignment: .topTrailing) {
                    AsyncImage(url: URL(string: food.imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(10)
                    
                    // Favorite Button
                    FavoriteButton(food: food)
                        .padding(6)
                        .background(Color.white.opacity(0.9))
                        .clipShape(Circle())
                        .padding(6)
                }
                
                // Food Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(food.name)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    Text(food.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("$\(String(format: "%.2f", food.price))")
                            .font(.subheadline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        
                        Spacer()
                        
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.yellow)
                            Text(String(format: "%.1f", food.rating))
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
            .background(Color(.systemBackground))
            .cornerRadius(10)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HomeView()
        .environmentObject(AppViewModel())
        .environmentObject(FoodViewModel())
        .environmentObject(CartViewModel())
} 
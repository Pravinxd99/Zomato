import SwiftUI

struct FoodDetailView: View {
    let food: Food
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var quantity: Int = 1
    @State private var showingAddedToCart: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header Image
                    headerImageView
                        .frame(height: geometry.size.height * 0.4)
                    
                    // Content
                    VStack(spacing: 20) {
                        // Food Info
                        foodInfoView
                        
                        // Description
                        descriptionView
                        
                        // Nutrition Info
                        nutritionView
                        
                        // Add to Cart Section
                        addToCartView
                    }
                    .padding(.horizontal, horizontalSizeClass == .compact ? 20 : 40)
                    .padding(.top, 20)
                }
            }
            .ignoresSafeArea(.all, edges: .top)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
                .foregroundColor(.primary)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                HStack(spacing: 15) {
                    FavoriteButton(food: food)
                    
                    Button(action: {
                        // Share food
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .alert("Added to Cart", isPresented: $showingAddedToCart) {
            Button("Continue Shopping") {
                dismiss()
            }
            Button("View Cart") {
                // Navigate to cart
                dismiss()
            }
        } message: {
            Text("\(food.name) has been added to your cart")
        }
    }
    
    // MARK: - Header Image View
    private var headerImageView: some View {
        ZStack {
            AsyncImage(url: URL(string: food.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .overlay(
                        Image(systemName: "photo")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                    )
            }
            
            // Gradient overlay
            LinearGradient(
                gradient: Gradient(colors: [Color.clear, Color.black.opacity(0.3)]),
                startPoint: .top,
                endPoint: .bottom
            )
            
            // Back button
            VStack {
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(Color.black.opacity(0.3))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding()
                Spacer()
            }
        }
    }
    
    // MARK: - Food Info View
    private var foodInfoView: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(food.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text(food.category.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.2))
                        .cornerRadius(20)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("$\(String(format: "%.2f", food.price))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                        Text(String(format: "%.1f", food.rating))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Food Tags
            HStack(spacing: 10) {
                if food.isVegetarian {
                    TagView(text: "Vegetarian", color: .green)
                }
                
                if food.isSpicy {
                    TagView(text: "Spicy", color: .red)
                }
                
                TagView(text: "\(food.preparationTime) min", color: .blue)
            }
        }
    }
    
    // MARK: - Description View
    private var descriptionView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Description")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(food.description)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(nil)
        }
    }
    
    // MARK: - Nutrition View
    private var nutritionView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Nutrition Info")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                NutritionCard(title: "Calories", value: "\(food.calories)", icon: "flame.fill", color: .orange)
                NutritionCard(title: "Prep Time", value: "\(food.preparationTime) min", icon: "clock.fill", color: .blue)
                NutritionCard(title: "Rating", value: String(format: "%.1f", food.rating), icon: "star.fill", color: .yellow)
            }
        }
    }
    
    // MARK: - Add to Cart View
    private var addToCartView: some View {
        VStack(spacing: 20) {
            // Quantity Selector
            HStack {
                Text("Quantity")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Spacer()
                
                HStack(spacing: 15) {
                    Button(action: {
                        if quantity > 1 {
                            quantity -= 1
                        }
                    }) {
                        Image(systemName: "minus.circle.fill")
                            .font(.title2)
                            .foregroundColor(quantity > 1 ? .orange : .gray)
                    }
                    .disabled(quantity <= 1)
                    
                    Text("\(quantity)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(minWidth: 40)
                    
                    Button(action: {
                        quantity += 1
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            // Price Info
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Total Price")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("$\(String(format: "%.2f", food.price * Double(quantity)))")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
                
                Spacer()
                
                Button(action: {
                    cartViewModel.addToCart(food, quantity: quantity)
                    showingAddedToCart = true
                }) {
                    HStack {
                        Image(systemName: "cart.badge.plus")
                            .font(.headline)
                        Text("Add to Cart")
                            .font(.headline)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 15)
                    .background(Color.orange)
                    .cornerRadius(25)
                }
            }
        }
        .padding(.vertical, 20)
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

// MARK: - Tag View
struct TagView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.2))
            .cornerRadius(12)
    }
}

// MARK: - Nutrition Card
struct NutritionCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        FoodDetailView(food: Food(
            id: "1",
            name: "Margherita Pizza",
            description: "Classic Italian pizza with tomato sauce, mozzarella cheese, and fresh basil. A perfect combination of flavors that will transport you to Italy.",
            price: 12.99,
            imageURL: "https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg",
            category: .pizza,
            rating: 4.8,
            preparationTime: 25,
            isVegetarian: true,
            isSpicy: false,
            calories: 285
        ))
        .environmentObject(CartViewModel())
    }
} 
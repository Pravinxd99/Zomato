import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var showingCheckout: Bool = false
    @State private var showingEmptyCart: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if cartViewModel.isEmpty {
                    emptyCartView
                } else {
                    cartContentView
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !cartViewModel.isEmpty {
                        Button("Clear") {
                            showingEmptyCart = true
                        }
                        .foregroundColor(.red)
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingCheckout) {
            CheckoutView()
                .environmentObject(cartViewModel)
                .environmentObject(appViewModel)
        }
        .alert("Clear Cart", isPresented: $showingEmptyCart) {
            Button("Cancel", role: .cancel) { }
            Button("Clear", role: .destructive) {
                cartViewModel.clearCart()
            }
        } message: {
            Text("Are you sure you want to clear your cart?")
        }
        .alert("Error", isPresented: $cartViewModel.showError) {
            Button("OK") {
                cartViewModel.clearError()
            }
        } message: {
            Text(cartViewModel.errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Empty Cart View
    private var emptyCartView: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "cart")
                .font(.system(size: 80))
                .foregroundColor(.gray)
            
            VStack(spacing: 10) {
                Text("Your cart is empty")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text("Add some delicious food to get started")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(action: {
                // Navigate to home
            }) {
                HStack {
                    Image(systemName: "house.fill")
                    Text("Browse Menu")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal, 30)
                .padding(.vertical, 15)
                .background(Color.orange)
                .cornerRadius(25)
            }
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    // MARK: - Cart Content View
    private var cartContentView: some View {
        VStack(spacing: 0) {
            // Cart Items List
            ScrollView {
                LazyVStack(spacing: 15) {
                    ForEach(cartViewModel.cartItems) { item in
                        CartItemRow(item: item) { action in
                            switch action {
                            case .increment:
                                cartViewModel.incrementQuantity(for: item.food)
                            case .decrement:
                                cartViewModel.decrementQuantity(for: item.food)
                            case .remove:
                                cartViewModel.removeFromCart(item.food)
                            }
                        }
                    }
                }
                .padding(.horizontal, horizontalSizeClass == .compact ? 16 : 24)
                .padding(.top, 20)
            }
            
            // Checkout Section
            checkoutSection
        }
    }
    
    // MARK: - Checkout Section
    private var checkoutSection: some View {
        VStack(spacing: 0) {
            Divider()
            
            VStack(spacing: 15) {
                // Summary
                VStack(spacing: 10) {
                    HStack {
                        Text("Subtotal")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.totalAmount))")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Delivery Fee")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$2.99")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Tax")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.totalAmount * 0.08))")
                            .fontWeight(.semibold)
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Total")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                        Text("$\(String(format: "%.2f", cartViewModel.totalAmount + 2.99 + (cartViewModel.totalAmount * 0.08)))")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
                .padding(.horizontal, 20)
                
                // Checkout Button
                Button(action: {
                    showingCheckout = true
                }) {
                    HStack {
                        if cartViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Text("Proceed to Checkout")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                }
                .disabled(cartViewModel.isLoading)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .background(Color(.systemBackground))
        }
    }
}

// MARK: - Cart Item Row
struct CartItemRow: View {
    let item: CartItem
    let onAction: (CartAction) -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            // Food Image
            AsyncImage(url: URL(string: item.food.imageURL)) { image in
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
            .frame(width: 80, height: 80)
            .clipped()
            .cornerRadius(10)
            
            // Food Info
            VStack(alignment: .leading, spacing: 8) {
                Text(item.food.name)
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(item.food.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("$\(String(format: "%.2f", item.food.price))")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    // Quantity Controls
                    HStack(spacing: 10) {
                        Button(action: {
                            onAction(.decrement)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.orange)
                        }
                        
                        Text("\(item.quantity)")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .frame(minWidth: 30)
                        
                        Button(action: {
                            onAction(.increment)
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Remove Button
            Button(action: {
                onAction(.remove)
            }) {
                Image(systemName: "trash")
                    .font(.title3)
                    .foregroundColor(.red)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Cart Action Enum
enum CartAction {
    case increment
    case decrement
    case remove
}

// MARK: - Checkout View
struct CheckoutView: View {
    @EnvironmentObject var cartViewModel: CartViewModel
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var deliveryAddress: String = ""
    @State private var paymentMethod: String = "Credit Card"
    @State private var showingOrderConfirmation: Bool = false
    
    private let paymentMethods = ["Credit Card", "Debit Card", "PayPal", "Cash on Delivery"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Order Summary
                    orderSummaryView
                    
                    // Delivery Address
                    deliveryAddressView
                    
                    // Payment Method
                    paymentMethodView
                    
                    // Place Order Button
                    placeOrderButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            deliveryAddress = appViewModel.currentUser?.address ?? ""
        }
        .alert("Order Placed", isPresented: $showingOrderConfirmation) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Your order has been placed successfully!")
        }
    }
    
    // MARK: - Order Summary View
    private var orderSummaryView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Order Summary")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            VStack(spacing: 10) {
                ForEach(cartViewModel.cartItems) { item in
                    HStack {
                        Text(item.food.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(item.quantity)x")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("$\(String(format: "%.2f", item.totalPrice))")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text("$\(String(format: "%.2f", cartViewModel.totalAmount))")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Delivery Address View
    private var deliveryAddressView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Delivery Address")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField("Enter delivery address", text: $deliveryAddress, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
    }
    
    // MARK: - Payment Method View
    private var paymentMethodView: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Payment Method")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Picker("Payment Method", selection: $paymentMethod) {
                ForEach(paymentMethods, id: \.self) { method in
                    Text(method).tag(method)
                }
            }
            .pickerStyle(MenuPickerStyle())
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
        }
    }
    
    // MARK: - Place Order Button
    private var placeOrderButton: some View {
        Button(action: {
            Task {
                await cartViewModel.placeOrder(
                    deliveryAddress: deliveryAddress,
                    paymentMethod: paymentMethod,
                    customerName: appViewModel.currentUser?.name ?? "Guest",
                    customerPhone: appViewModel.currentUser?.phone ?? ""
                )
                showingOrderConfirmation = true
            }
        }) {
            HStack {
                if cartViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Place Order")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.orange)
            .foregroundColor(.white)
            .cornerRadius(15)
        }
        .disabled(cartViewModel.isLoading || deliveryAddress.isEmpty)
        .opacity(deliveryAddress.isEmpty ? 0.6 : 1.0)
    }
}

#Preview {
    CartView()
        .environmentObject(CartViewModel())
        .environmentObject(AppViewModel())
} 
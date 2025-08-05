import Foundation
import SwiftUI

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    @Published var showOrderConfirmation: Bool = false
    @Published var currentOrder: Order?
    
    private let coreDataService = CoreDataService.shared
    
    // MARK: - Computed Properties
    var totalItems: Int {
        return cartItems.reduce(0) { $0 + $1.quantity }
    }
    
    var totalAmount: Double {
        return cartItems.reduce(0) { $0 + $1.totalPrice }
    }
    
    var isEmpty: Bool {
        return cartItems.isEmpty
    }
    
    // MARK: - Cart Operations
    func addToCart(_ food: Food, quantity: Int = 1) {
        if let existingIndex = cartItems.firstIndex(where: { $0.food.id == food.id }) {
            cartItems[existingIndex].quantity += quantity
        } else {
            let newItem = CartItem(food: food, quantity: quantity)
            cartItems.append(newItem)
        }
    }
    
    func removeFromCart(_ food: Food) {
        cartItems.removeAll { $0.food.id == food.id }
    }
    
    func updateQuantity(for food: Food, quantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.food.id == food.id }) {
            if quantity <= 0 {
                cartItems.remove(at: index)
            } else {
                cartItems[index].quantity = quantity
            }
        }
    }
    
    func incrementQuantity(for food: Food) {
        if let index = cartItems.firstIndex(where: { $0.food.id == food.id }) {
            cartItems[index].quantity += 1
        }
    }
    
    func decrementQuantity(for food: Food) {
        if let index = cartItems.firstIndex(where: { $0.food.id == food.id }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
            } else {
                cartItems.remove(at: index)
            }
        }
    }
    
    func clearCart() {
        cartItems.removeAll()
    }
    
    // MARK: - Order Management
    func placeOrder(deliveryAddress: String, paymentMethod: String, customerName: String, customerPhone: String) async {
        guard !cartItems.isEmpty else {
            showError("Cart is empty")
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let estimatedDeliveryTime = Calendar.current.date(byAdding: .minute, value: 45, to: Date()) ?? Date()
            
            let order = Order(
                items: cartItems,
                totalAmount: totalAmount,
                status: .pending,
                orderDate: Date(),
                deliveryAddress: deliveryAddress,
                estimatedDeliveryTime: estimatedDeliveryTime,
                paymentMethod: paymentMethod,
                customerName: customerName,
                customerPhone: customerPhone
            )
            
            // Save order to Core Data
            try await coreDataService.saveOrder(order)
            
            // Clear cart after successful order
            clearCart()
            
            // Set current order for confirmation
            currentOrder = order
            showOrderConfirmation = true
            
        } catch {
            errorMessage = "Failed to place order: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    func updateOrderStatus(orderId: String, status: OrderStatus) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await coreDataService.updateOrderStatus(orderId: orderId, status: status)
        } catch {
            errorMessage = "Failed to update order status: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    func cancelOrder(orderId: String) async {
        await updateOrderStatus(orderId: orderId, status: .cancelled)
    }
    
    // MARK: - Order Retrieval
    func fetchOrders() async -> [Order] {
        isLoading = true
        errorMessage = nil
        
        do {
            let orders = try await coreDataService.fetchOrders()
            isLoading = false
            return orders
        } catch {
            errorMessage = "Failed to fetch orders: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return []
        }
    }
    
    func fetchOrder(by id: String) async -> Order? {
        isLoading = true
        errorMessage = nil
        
        do {
            let order = try await coreDataService.fetchOrder(by: id)
            isLoading = false
            return order
        } catch {
            errorMessage = "Failed to fetch order: \(error.localizedDescription)"
            showError = true
            isLoading = false
            return nil
        }
    }
    
    func deleteOrder(orderId: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await coreDataService.deleteOrder(orderId: orderId)
        } catch {
            errorMessage = "Failed to delete order: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    // MARK: - Statistics
    func getOrderStatistics() async -> (totalOrders: Int, totalSpent: Double, averageOrderValue: Double) {
        do {
            return try await coreDataService.getOrderStatistics()
        } catch {
            errorMessage = "Failed to get statistics: \(error.localizedDescription)"
            showError = true
            return (0, 0, 0)
        }
    }
    
    func getOrdersByStatus() async -> [OrderStatus: Int] {
        do {
            return try await coreDataService.getOrdersByStatus()
        } catch {
            errorMessage = "Failed to get order status: \(error.localizedDescription)"
            showError = true
            return [:]
        }
    }
    
    // MARK: - Helper Methods
    func getCartItem(for food: Food) -> CartItem? {
        return cartItems.first { $0.food.id == food.id }
    }
    
    func isInCart(_ food: Food) -> Bool {
        return cartItems.contains { $0.food.id == food.id }
    }
    
    func getQuantity(for food: Food) -> Int {
        return getCartItem(for: food)?.quantity ?? 0
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
    
    func dismissOrderConfirmation() {
        showOrderConfirmation = false
        currentOrder = nil
    }
} 
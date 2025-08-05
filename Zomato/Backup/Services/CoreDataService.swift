import Foundation
import CoreData

class CoreDataService {
    static let shared = CoreDataService()
    private let persistenceController = PersistenceController.shared
    
    private init() {}
    
    // MARK: - Order Management
    func saveOrder(_ order: Order) async throws {
        let context = persistenceController.container.viewContext
        
        // Check if order already exists
        let fetchRequest: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", order.id)
        
        do {
            let existingOrders = try context.fetch(fetchRequest)
            if let existingOrder = existingOrders.first {
                // Update existing order
                existingOrder.totalAmount = order.totalAmount
                existingOrder.status = order.status.rawValue
                existingOrder.deliveryAddress = order.deliveryAddress
                existingOrder.estimatedDeliveryTime = order.estimatedDeliveryTime
                existingOrder.paymentMethod = order.paymentMethod
                existingOrder.customerName = order.customerName
                existingOrder.customerPhone = order.customerPhone
                
                // Remove existing order items
                if let existingItems = existingOrder.orderItems as? Set<CDOrderItem> {
                    for item in existingItems {
                        context.delete(item)
                    }
                }
                
                // Add new order items
                for item in order.items {
                    let cdOrderItem = CDOrderItem(context: context)
                    cdOrderItem.id = item.id.uuidString
                    cdOrderItem.foodId = item.food.id
                    cdOrderItem.foodName = item.food.name
                    cdOrderItem.foodDescription = item.food.description
                    cdOrderItem.foodPrice = item.food.price
                    cdOrderItem.foodImageURL = item.food.imageURL
                    cdOrderItem.foodCategory = item.food.category.rawValue
                    cdOrderItem.quantity = Int32(item.quantity)
                    cdOrderItem.order = existingOrder
                }
            } else {
                // Create new order
                _ = order.toCDOrder(context: context)
            }
            
            try context.save()
        } catch {
            throw error
        }
    }
    
    func fetchOrders() async throws -> [Order] {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "orderDate", ascending: false)]
        
        do {
            let cdOrders = try context.fetch(fetchRequest)
            return cdOrders.map { $0.toOrder() }
        } catch {
            throw error
        }
    }
    
    func fetchOrder(by id: String) async throws -> Order? {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let cdOrders = try context.fetch(fetchRequest)
            return cdOrders.first?.toOrder()
        } catch {
            throw error
        }
    }
    
    func updateOrderStatus(orderId: String, status: OrderStatus) async throws {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderId)
        
        do {
            let cdOrders = try context.fetch(fetchRequest)
            if let order = cdOrders.first {
                order.status = status.rawValue
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    func deleteOrder(orderId: String) async throws {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDOrder> = CDOrder.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", orderId)
        
        do {
            let cdOrders = try context.fetch(fetchRequest)
            if let order = cdOrders.first {
                context.delete(order)
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - User Management
    func saveUser(_ user: User) async throws {
        let context = persistenceController.container.viewContext
        
        // Check if user already exists
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", user.id)
        
        do {
            let existingUsers = try context.fetch(fetchRequest)
            if let existingUser = existingUsers.first {
                // Update existing user
                existingUser.name = user.name
                existingUser.email = user.email
                existingUser.phone = user.phone
                existingUser.address = user.address
                existingUser.profileImageURL = user.profileImageURL
                existingUser.isLoggedIn = true
            } else {
                // Create new user
                _ = user.toCDUser(context: context)
            }
            
            try context.save()
        } catch {
            throw error
        }
    }
    
    func fetchUser(by id: String) async throws -> User? {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        fetchRequest.fetchLimit = 1
        
        do {
            let cdUsers = try context.fetch(fetchRequest)
            return cdUsers.first?.toUser()
        } catch {
            throw error
        }
    }
    
    func fetchLoggedInUser() async throws -> User? {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "isLoggedIn == YES")
        fetchRequest.fetchLimit = 1
        
        do {
            let cdUsers = try context.fetch(fetchRequest)
            return cdUsers.first?.toUser()
        } catch {
            throw error
        }
    }
    
    func updateUserProfile(userId: String, name: String, phone: String, address: String, profileImageURL: String?) async throws {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            let cdUsers = try context.fetch(fetchRequest)
            if let user = cdUsers.first {
                user.name = name
                user.phone = phone
                user.address = address
                user.profileImageURL = profileImageURL
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    func logoutUser(userId: String) async throws {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            let cdUsers = try context.fetch(fetchRequest)
            if let user = cdUsers.first {
                user.isLoggedIn = false
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    func deleteUser(userId: String) async throws {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<CDUser> = CDUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", userId)
        
        do {
            let cdUsers = try context.fetch(fetchRequest)
            if let user = cdUsers.first {
                context.delete(user)
                try context.save()
            }
        } catch {
            throw error
        }
    }
    
    // MARK: - Statistics
    func getOrderStatistics() async throws -> (totalOrders: Int, totalSpent: Double, averageOrderValue: Double) {
        let orders = try await fetchOrders()
        let totalOrders = orders.count
        let totalSpent = orders.reduce(0) { $0 + $1.totalAmount }
        let averageOrderValue = totalOrders > 0 ? totalSpent / Double(totalOrders) : 0
        
        return (totalOrders, totalSpent, averageOrderValue)
    }
    
    func getOrdersByStatus() async throws -> [OrderStatus: Int] {
        let orders = try await fetchOrders()
        var statusCount: [OrderStatus: Int] = [:]
        
        for status in OrderStatus.allCases {
            statusCount[status] = orders.filter { $0.status == status }.count
        }
        
        return statusCount
    }
} 
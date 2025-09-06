import Foundation
import CoreData

// MARK: - Enums
enum OrderStatus: String, CaseIterable, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case preparing = "Preparing"
    case outForDelivery = "Out for Delivery"
    case delivered = "Delivered"
    case cancelled = "Cancelled"
    case inProcess = "In Process"
    
    var color: String {
        switch self {
        case .pending: return "orange"
        case .confirmed: return "blue"
        case .preparing: return "purple"
        case .outForDelivery: return "yellow"
        case .delivered: return "green"
        case .cancelled: return "red"
        case .inProcess: return "teal"
        }
    }
}

enum FoodCategory: String, CaseIterable, Codable {
    case pizza = "Pizza"
    case burger = "Burger"
    case pasta = "Pasta"
    case salad = "Salad"
    case dessert = "Dessert"
    case beverage = "Beverage"
    case appetizer = "Appetizer"
    case mainCourse = "Main Course"
    
    var icon: String {
        switch self {
        case .pizza: return "🍕"
        case .burger: return "🍔"
        case .pasta: return "🍝"
        case .salad: return "🥗"
        case .dessert: return "🍰"
        case .beverage: return "🥤"
        case .appetizer: return "🥨"
        case .mainCourse: return "🍽️"
        }
    }
}

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError:
            return "Failed to decode data"
        case .serverError(let message):
            return "Server error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

// MARK: - Models
struct Food: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let price: Double
    let imageURL: String
    let category: FoodCategory
    let rating: Double
    let preparationTime: Int // in minutes
    let isVegetarian: Bool
    let isSpicy: Bool
    let calories: Int
    
    enum CodingKeys: String, CodingKey {
        case id = "idMeal"
        case name = "strMeal"
        case description = "strInstructions"
        case price = "price"
        case imageURL = "strMealThumb"
        case category = "category"
        case rating = "rating"
        case preparationTime = "prepTime"
        case isVegetarian = "isVegetarian"
        case isSpicy = "isSpicy"
        case calories = "calories"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        
        // Handle price - if not available in API, generate random price
        if let price = try? container.decode(Double.self, forKey: .price) {
            self.price = price
        } else {
            self.price = Double.random(in: 8.0...25.0)
        }
        
        imageURL = try container.decode(String.self, forKey: .imageURL)
        
        // Handle category - if not available in API, assign random category
        if let categoryString = try? container.decode(String.self, forKey: .category),
           let category = FoodCategory(rawValue: categoryString) {
            self.category = category
        } else {
            self.category = FoodCategory.allCases.randomElement() ?? .mainCourse
        }
        
        // Handle rating - if not available in API, generate random rating
        if let rating = try? container.decode(Double.self, forKey: .rating) {
            self.rating = rating
        } else {
            self.rating = Double.random(in: 3.5...5.0)
        }
        
        // Handle preparation time - if not available in API, generate random time
        if let prepTime = try? container.decode(Int.self, forKey: .preparationTime) {
            self.preparationTime = prepTime
        } else {
            self.preparationTime = Int.random(in: 15...45)
        }
        
        // Handle boolean properties
        if let isVegetarian = try? container.decode(Bool.self, forKey: .isVegetarian) {
            self.isVegetarian = isVegetarian
        } else {
            self.isVegetarian = Bool.random()
        }
        
        if let isSpicy = try? container.decode(Bool.self, forKey: .isSpicy) {
            self.isSpicy = isSpicy
        } else {
            self.isSpicy = Bool.random()
        }
        
        // Handle calories - if not available in API, generate random calories
        if let calories = try? container.decode(Int.self, forKey: .calories) {
            self.calories = calories
        } else {
            self.calories = Int.random(in: 200...800)
        }
    }
}

struct User: Codable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let address: String
    let profileImageURL: String?
    
    init(id: String = UUID().uuidString, name: String, email: String, phone: String, address: String, profileImageURL: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.phone = phone
        self.address = address
        self.profileImageURL = profileImageURL
    }
}

struct CartItem: Identifiable, Codable {
    let id = UUID()
    let food: Food
    var quantity: Int
    
    var totalPrice: Double {
        return food.price * Double(quantity)
    }
}

struct Order: Identifiable, Codable {
    let id: String
    let items: [CartItem]
    let totalAmount: Double
    let status: OrderStatus
    let orderDate: Date
    let deliveryAddress: String
    let estimatedDeliveryTime: Date
    let paymentMethod: String
    let customerName: String
    let customerPhone: String
    
    init(id: String = UUID().uuidString, items: [CartItem], totalAmount: Double, status: OrderStatus = .pending, orderDate: Date = Date(), deliveryAddress: String, estimatedDeliveryTime: Date, paymentMethod: String, customerName: String, customerPhone: String) {
        self.id = id
        self.items = items
        self.totalAmount = totalAmount
        self.status = status
        self.orderDate = orderDate
        self.deliveryAddress = deliveryAddress
        self.estimatedDeliveryTime = estimatedDeliveryTime
        self.paymentMethod = paymentMethod
        self.customerName = customerName
        self.customerPhone = customerPhone
    }
}

// MARK: - API Response Models
struct FoodAPIResponse: Codable {
    let meals: [Food]?
}

struct CategoryAPIResponse: Codable {
    let categories: [Category]?
}

struct Category: Codable {
    let idCategory: String
    let strCategory: String
    let strCategoryThumb: String
    let strCategoryDescription: String
}

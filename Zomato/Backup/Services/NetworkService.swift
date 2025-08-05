import Foundation

class NetworkService {
    static let shared = NetworkService()
    private let baseURL = "https://www.themealdb.com/api/json/v1/1"
    
    private init() {}
    
    // MARK: - Generic Network Methods
    func fetch<T: Codable>(_ endpoint: String, method: HTTPMethod = .GET, body: Data? = nil) async throws -> T {
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = body {
            request.httpBody = body
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.serverError("Invalid response")
            }
            
            guard httpResponse.statusCode >= 200 && httpResponse.statusCode < 300 else {
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }
            
            guard !data.isEmpty else {
                throw NetworkError.noData
            }
            
            do {
                let decodedData = try JSONDecoder().decode(T.self, from: data)
                return decodedData
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
        } catch {
            if let networkError = error as? NetworkError {
                throw networkError
            } else {
                throw NetworkError.networkError(error)
            }
        }
    }
    
    // MARK: - Food API Methods
    func fetchRandomMeals(count: Int = 20) async throws -> [Food] {
        var meals: [Food] = []
        
        for _ in 0..<count {
            do {
                let response: FoodAPIResponse = try await fetch("/random.php")
                if let meal = response.meals?.first {
                    meals.append(meal)
                }
            } catch {
                print("Error fetching random meal: \(error)")
                // Continue with other meals even if one fails
            }
        }
        
        return meals
    }
    
    func fetchMealsByCategory(_ category: String) async throws -> [Food] {
        let response: FoodAPIResponse = try await fetch("/filter.php?c=\(category)")
        return response.meals ?? []
    }
    
    func fetchMealById(_ id: String) async throws -> Food? {
        let response: FoodAPIResponse = try await fetch("/lookup.php?i=\(id)")
        return response.meals?.first
    }
    
    func searchMeals(query: String) async throws -> [Food] {
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let response: FoodAPIResponse = try await fetch("/search.php?s=\(encodedQuery)")
        return response.meals ?? []
    }
    
    func fetchCategories() async throws -> [Category] {
        let response: CategoryAPIResponse = try await fetch("/categories.php")
        return response.categories ?? []
    }
    
    // MARK: - Mock Data for Development
    func getMockFoods() -> [Food] {
        return [
            Food(id: "1", name: "Margherita Pizza", description: "Classic Italian pizza with tomato sauce, mozzarella cheese, and fresh basil", price: 12.99, imageURL: "https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg", category: .pizza, rating: 4.8, preparationTime: 25, isVegetarian: true, isSpicy: false, calories: 285),
            Food( id: "2", name: "Chicken Burger", description: "Juicy chicken patty with lettuce, tomato, and special sauce", price: 9.99, imageURL: "https://www.themealdb.com/images/media/meals/1550441275.jpg", category: .burger, rating: 4.5, preparationTime: 20, isVegetarian: false, isSpicy: false, calories: 450),
            Food(id: "3", name: "Spaghetti Carbonara", description: "Traditional Italian pasta with eggs, cheese, pancetta, and black pepper", price: 14.99, imageURL: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg", category: .pasta, rating: 4.7, preparationTime: 30, isVegetarian: false, isSpicy: false, calories: 520),
            Food(id: "4", name: "Caesar Salad", description: "Fresh romaine lettuce with Caesar dressing, croutons, and parmesan cheese", price: 8.99, imageURL: "https://www.themealdb.com/images/media/meals/1550441275.jpg", category: .salad, rating: 4.3, preparationTime: 15, isVegetarian: true, isSpicy: false, calories: 180),
            Food(id: "5", name: "Chocolate Cake", description: "Rich chocolate cake with chocolate frosting and sprinkles", price: 6.99, imageURL: "https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg", category: .dessert, rating: 4.9, preparationTime: 45, isVegetarian: true, isSpicy: false, calories: 350),
            Food(id: "6", name: "Iced Latte", description: "Smooth espresso with cold milk and ice", price: 4.99, imageURL: "https://www.themealdb.com/images/media/meals/1550441275.jpg", category: .beverage, rating: 4.4, preparationTime: 5, isVegetarian: true, isSpicy: false, calories: 120),
            Food(id: "7", name: "Garlic Bread", description: "Toasted bread with garlic butter and herbs", price: 3.99, imageURL: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg", category: .appetizer, rating: 4.2, preparationTime: 10, isVegetarian: true, isSpicy: false, calories: 150),
            Food(id: "8", name: "Grilled Salmon", description: "Fresh salmon fillet grilled to perfection with herbs and lemon", price: 18.99, imageURL: "https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg", category: .mainCourse, rating: 4.6, preparationTime: 35, isVegetarian: false, isSpicy: false, calories: 380),
            Food(id: "9", name: "Pepperoni Pizza", description: "Spicy pepperoni pizza with melted cheese and tomato sauce", price: 13.99, imageURL: "https://www.themealdb.com/images/media/meals/1550441275.jpg", category: .pizza, rating: 4.7, preparationTime: 25, isVegetarian: false, isSpicy: true, calories: 320),
            Food(id: "10", name: "Veggie Burger", description: "Plant-based burger with fresh vegetables and special sauce", price: 10.99, imageURL: "https://www.themealdb.com/images/media/meals/llcbn01574260722.jpg", category: .burger, rating: 4.4, preparationTime: 20, isVegetarian: true, isSpicy: false, calories: 280)
        ]
    }
}

// MARK: - HTTP Method Enum
enum HTTPMethod: String {
    case GET = "GET"
    case POST = "POST"
    case PUT = "PUT"
    case DELETE = "DELETE"
} 

import Foundation

class UserDefaultsService {
    static let shared = UserDefaultsService()
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let isLoggedIn = "isLoggedIn"
        static let userEmail = "userEmail"
        static let userPassword = "userPassword"
        static let userName = "userName"
        static let userPhone = "userPhone"
        static let userAddress = "userAddress"
        static let userProfileImage = "userProfileImage"
        static let lastLoginDate = "lastLoginDate"
        static let rememberMe = "rememberMe"
        static let nickName = "nickName"
    }
    
    private init() {
        // Create test user account if none exists
        createTestUserIfNeeded()
    }
    
    // MARK: - Test User Creation
    private func createTestUserIfNeeded() {
        if !userDefaults.bool(forKey: Keys.isLoggedIn) {
            saveUserCredentials(
                email: "test@zomato.com",
                password: "password123",
                name: "Test User",
                phone: "1234567890",
                address: "123 Test Street, Test City, TC 12345"
            )
        }
    }
    
    // MARK: - Authentication Methods
    func saveUserCredentials(email: String, password: String, name: String, phone: String, address: String) {
        userDefaults.set(true, forKey: Keys.isLoggedIn)
        userDefaults.set(email, forKey: Keys.userEmail)
        userDefaults.set(password, forKey: Keys.userPassword)
        userDefaults.set(name, forKey: Keys.userName)
        userDefaults.set(phone, forKey: Keys.userPhone)
        userDefaults.set(address, forKey: Keys.userAddress)
        userDefaults.set(Date(), forKey: Keys.lastLoginDate)
    }
    
    func login(email: String, password: String) -> Bool {
        let savedEmail = userDefaults.string(forKey: Keys.userEmail) ?? ""
        let savedPassword = userDefaults.string(forKey: Keys.userPassword) ?? ""
        
        if email == savedEmail && password == savedPassword {
            userDefaults.set(true, forKey: Keys.isLoggedIn)
            userDefaults.set(Date(), forKey: Keys.lastLoginDate)
            return true
        }
        return false
    }
    
    func logout() {
        userDefaults.set(false, forKey: Keys.isLoggedIn)
        userDefaults.removeObject(forKey: Keys.lastLoginDate)
    }
    
    func isLoggedIn() -> Bool {
        return userDefaults.bool(forKey: Keys.isLoggedIn)
    }
    
    func getCurrentUser() -> User? {
        guard isLoggedIn() else { return nil }
        
        let name = userDefaults.string(forKey: Keys.userName) ?? ""
        let email = userDefaults.string(forKey: Keys.userEmail) ?? ""
        let phone = userDefaults.string(forKey: Keys.userPhone) ?? ""
        let address = userDefaults.string(forKey: Keys.userAddress) ?? ""
        let profileImage = userDefaults.string(forKey: Keys.userProfileImage)
        
        return User(
            name: name,
            email: email,
            phone: phone,
            address: address,
            profileImageURL: profileImage
        )
    }
    
    func updateUserProfile(name: String, phone: String, address: String, profileImageURL: String?) {
        userDefaults.set(name, forKey: Keys.userName)
        userDefaults.set(phone, forKey: Keys.userPhone)
        userDefaults.set(address, forKey: Keys.userAddress)
        if let profileImageURL = profileImageURL {
            userDefaults.set(profileImageURL, forKey: Keys.userProfileImage)
        }
    }
    
    func updateProfileImage(_ imageURL: String) {
        userDefaults.set(imageURL, forKey: Keys.userProfileImage)
    }
    
    func getLastLoginDate() -> Date? {
        return userDefaults.object(forKey: Keys.lastLoginDate) as? Date
    }
    
    func setRememberMe(_ remember: Bool) {
        userDefaults.set(remember, forKey: Keys.rememberMe)
    }
    
    func getRememberMe() -> Bool {
        return userDefaults.bool(forKey: Keys.rememberMe)
    }
    
    // MARK: - Clear All Data
    func clearAllData() {
        let domain = Bundle.main.bundleIdentifier!
        userDefaults.removePersistentDomain(forName: domain)
    }
    
    // MARK: - Validation Methods
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        return password.count >= 6
    }
    
    func isValidPhone(_ phone: String) -> Bool {
        let phoneRegex = "^[0-9]{10}$"
        let phonePredicate = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phonePredicate.evaluate(with: phone)
    }
} 

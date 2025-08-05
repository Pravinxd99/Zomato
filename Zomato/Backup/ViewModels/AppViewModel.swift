import Foundation
import SwiftUI

@MainActor
class AppViewModel: ObservableObject {
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    private let userDefaultsService = UserDefaultsService.shared
    private let coreDataService = CoreDataService.shared
    
    init() {
        checkLoginStatus()
    }
    
    // MARK: - Authentication
    func checkLoginStatus() {
        isLoggedIn = userDefaultsService.isLoggedIn()
        if isLoggedIn {
            currentUser = userDefaultsService.getCurrentUser()
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let success = userDefaultsService.login(email: email, password: password)
            if success {
                isLoggedIn = true
                currentUser = userDefaultsService.getCurrentUser()
                
                // Save user to Core Data
                if let user = currentUser {
                    try await coreDataService.saveUser(user)
                }
            } else {
                errorMessage = "Invalid email or password"
                showError = true
            }
        } catch {
            errorMessage = "Login failed: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    func register(name: String, email: String, password: String, phone: String, address: String) async {
        isLoading = true
        errorMessage = nil
        
        do {
            // Validate input
            guard userDefaultsService.isValidEmail(email) else {
                errorMessage = "Please enter a valid email address"
                showError = true
                isLoading = false
                return
            }
            
            guard userDefaultsService.isValidPassword(password) else {
                errorMessage = "Password must be at least 6 characters long"
                showError = true
                isLoading = false
                return
            }
            
            guard userDefaultsService.isValidPhone(phone) else {
                errorMessage = "Please enter a valid 10-digit phone number"
                showError = true
                isLoading = false
                return
            }
            
            // Save user credentials
            userDefaultsService.saveUserCredentials(email: email, password: password, name: name, phone: phone, address: address)
            
            // Create user object
            let user = User(name: name, email: email, phone: phone, address: address)
            
            // Save to Core Data
            try await coreDataService.saveUser(user)
            
            isLoggedIn = true
            currentUser = user
        } catch {
            errorMessage = "Registration failed: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    func logout() async {
        isLoading = true
        
        do {
            // Logout from UserDefaults
            userDefaultsService.logout()
            
            // Logout from Core Data
            if let user = currentUser {
                try await coreDataService.logoutUser(userId: user.id)
            }
            
            isLoggedIn = false
            currentUser = nil
        } catch {
            errorMessage = "Logout failed: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
    }
    
    func updateProfile(name: String, phone: String, address: String, profileImageURL: String?) async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let user = currentUser else {
                errorMessage = "User not found"
                showError = true
                isLoading = false
                return
            }
            
            // Update UserDefaults
            userDefaultsService.updateUserProfile(name: name, phone: phone, address: address, profileImageURL: profileImageURL)
            
            // Update Core Data
            try await coreDataService.updateUserProfile(userId: user.id, name: name, phone: phone, address: address, profileImageURL: profileImageURL)
            
            // Update current user
            currentUser = User(
                id: user.id,
                name: name,
                email: user.email,
                phone: phone,
                address: address,
                profileImageURL: profileImageURL
            )
        } catch {
            errorMessage = "Profile update failed: \(error.localizedDescription)"
            showError = true
        }
        
        isLoading = false
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
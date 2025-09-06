import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @EnvironmentObject var cartViewModel: CartViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var showingEditProfile: Bool = false
    @State private var showingLogoutAlert: Bool = false
    @State private var showingDeleteAccountAlert: Bool = false
    @State private var statistics: (totalOrders: Int, totalSpent: Double, averageOrderValue: Double) = (0, 0, 0)
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 21) {
                    // Profile Header
                    profileHeaderView
                    
                    // Statistics
                    statisticsView
                    
                    // Menu Items
                    menuItemsView
                }
                .padding(.horizontal, horizontalSizeClass == .compact ? 16 : 24)
                .padding(.top, 20)
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Edit") {
                        showingEditProfile = true
                    }
                    .foregroundColor(.orange)
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
                .environmentObject(appViewModel)
        }
        .alert("Logout", isPresented: $showingLogoutAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Logout", role: .destructive) {
                Task {
                    await appViewModel.logout()
                }
            }
        } message: {
            Text("Are you sure you want to logout?")
        }
        .alert("Delete Account", isPresented: $showingDeleteAccountAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // Handle account deletion
            }
        } message: {
            Text("This action cannot be undone. All your data will be permanently deleted.")
        }
        .onAppear {
            loadStatistics()
        }
    }
    
    // MARK: - Profile Header View
    private var profileHeaderView: some View {
        VStack(spacing: 20) {
            // Profile Image
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                if let user = appViewModel.currentUser, let imageURL = user.profileImageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                }
                
                // Edit Button
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showingEditProfile = true
                        }) {
                            Image(systemName: "camera.fill")
                                .font(.caption)
                                .foregroundColor(.white)
                                .frame(width: 30, height: 30)
                                .background(Color.orange)
                                .clipShape(Circle())
                        }
                    }
                }
            }
            
            // User Info
            VStack(spacing: 8) {
                Text(appViewModel.currentUser?.name ?? "Guest User")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text(appViewModel.currentUser?.email ?? "guest@example.com")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                if let lastLogin = UserDefaultsService.shared.getLastLoginDate() {
                    Text("Last login: \(lastLogin, style: .date)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
    
    // MARK: - Statistics View
    private var statisticsView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Your Statistics")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Total Orders",
                    value: "\(statistics.totalOrders)",
                    icon: "bag.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Total Spent",
                    value: "$\(String(format: "%.0f", statistics.totalSpent))",
                    icon: "dollarsign.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Avg. Order",
                    value: "$\(String(format: "%.0f", statistics.averageOrderValue))",
                    icon: "chart.bar.fill",
                    color: .orange
                )
            }
        }
    }
    
    // MARK: - Menu Items View
    private var menuItemsView: some View {
        VStack(spacing: 15) {
            // Account Section
            MenuSection(title: "Account") {
                MenuRow(
                    icon: "person.fill",
                    title: "Edit Profile",
                    color: .blue
                ) {
                    showingEditProfile = true
                }
                
                MenuRow(
                    icon: "location.fill",
                    title: "Delivery Address",
                    color: .green
                ) {
                    // Navigate to address settings
                }
                
                MenuRow(
                    icon: "creditcard.fill",
                    title: "Payment Methods",
                    color: .purple
                ) {
                    // Navigate to payment settings
                }
            }
            
            // Orders Section
            MenuSection(title: "Orders") {
                MenuRow(
                    icon: "bag.fill",
                    title: "Order History",
                    color: .orange
                ) {
                    // Navigate to orders
                }
                
                MenuRow(
                    icon: "clock.fill",
                    title: "Track Orders",
                    color: .blue
                ) {
                    // Navigate to order tracking
                }
            }
            
            // Settings Section
            MenuSection(title: "Settings") {
                MenuRow(
                    icon: "bell.fill",
                    title: "Notifications",
                    color: .red
                ) {
                    // Navigate to notifications
                }
                
                MenuRow(
                    icon: "shield.fill",
                    title: "Privacy & Security",
                    color: .green
                ) {
                    // Navigate to privacy settings
                }
                
                MenuRow(
                    icon: "questionmark.circle.fill",
                    title: "Help & Support",
                    color: .blue
                ) {
                    // Navigate to help
                }
                
                MenuRow(
                    icon: "info.circle.fill",
                    title: "About",
                    color: .gray
                ) {
                    // Show about info
                }
            }
            
            // Account Actions Section
            MenuSection(title: "Account Actions") {
                MenuRow(
                    icon: "arrow.right.square.fill",
                    title: "Logout",
                    color: .orange
                ) {
                    showingLogoutAlert = true
                }
                
                MenuRow(
                    icon: "trash.fill",
                    title: "Delete Account",
                    color: .red
                ) {
                    showingDeleteAccountAlert = true
                }
            }
        }
    }
    
    // MARK: - Load Statistics
    private func loadStatistics() {
        Task {
            statistics = await cartViewModel.getOrderStatistics()
        }
    }
}

// MARK: - Menu Section
struct MenuSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            VStack(spacing: 0) {
                content
            }
            .background(Color(.systemBackground))
            .cornerRadius(15)
            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 1)
        }
    }
}

// MARK: - Menu Row
struct MenuRow: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                    .frame(width: 25)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var address: String = ""
    @State private var showingImagePicker: Bool = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image
                    profileImageView
                    
                    // Form Fields
                    formFieldsView
                    
                    // Save Button
                    saveButton
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .navigationTitle("Edit Profile")
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
            loadUserData()
        }
        .alert("Error", isPresented: $appViewModel.showError) {
            Button("OK") {
                appViewModel.clearError()
            }
        } message: {
            Text(appViewModel.errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Profile Image View
    private var profileImageView: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.2))
                    .frame(width: 120, height: 120)
                
                if let user = appViewModel.currentUser, let imageURL = user.profileImageURL {
                    AsyncImage(url: URL(string: imageURL)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Image(systemName: "person.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.orange)
                    }
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                } else {
                    Image(systemName: "person.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                }
            }
            
            Button("Change Photo") {
                showingImagePicker = true
            }
            .font(.subheadline)
            .foregroundColor(.orange)
        }
    }
    
    // MARK: - Form Fields View
    private var formFieldsView: some View {
        VStack(spacing: 20) {
            // Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter your full name", text: $name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter your email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .disabled(true)
            }
            
            // Phone Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter your phone number", text: $phone)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.phonePad)
            }
            
            // Address Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Delivery Address")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                TextField("Enter your delivery address", text: $address, axis: .vertical)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .lineLimit(3...6)
            }
        }
    }
    
    // MARK: - Save Button
    private var saveButton: some View {
        Button(action: {
            Task {
                await appViewModel.updateProfile(
                    name: name,
                    phone: phone,
                    address: address,
                    profileImageURL: appViewModel.currentUser?.profileImageURL
                )
                dismiss()
            }
        }) {
            HStack {
                if appViewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text("Save Changes")
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
        .disabled(appViewModel.isLoading || name.isEmpty || phone.isEmpty || address.isEmpty)
        .opacity((name.isEmpty || phone.isEmpty || address.isEmpty) ? 0.6 : 1.0)
    }
    
    // MARK: - Load User Data
    private func loadUserData() {
        if let user = appViewModel.currentUser {
            name = user.name
            email = user.email
            phone = user.phone
            address = user.address
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppViewModel())
        .environmentObject(CartViewModel())
} 

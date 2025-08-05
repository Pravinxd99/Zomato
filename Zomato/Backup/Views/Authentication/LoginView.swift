import SwiftUI

struct LoginView: View {
    @EnvironmentObject var appViewModel: AppViewModel
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isSignUp: Bool = false
    @State private var showPassword: Bool = false
    @State private var rememberMe: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Form
                    formView
                        .padding(.horizontal, horizontalSizeClass == .compact ? 20 : 40)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // Footer
                    footerView
                        .padding(.horizontal, horizontalSizeClass == .compact ? 20 : 40)
                        .padding(.bottom, 20)
                }
                .frame(minHeight: geometry.size.height)
            }
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.orange.opacity(0.1), Color.red.opacity(0.1)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .alert("Error", isPresented: $appViewModel.showError) {
            Button("OK") {
                appViewModel.clearError()
            }
        } message: {
            Text(appViewModel.errorMessage ?? "An error occurred")
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        VStack(spacing: 20) {
            // Logo
            VStack(spacing: 10) {
                Image(systemName: "fork.knife.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.orange)
                
                Text("Zomato")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
                Text("Delicious food delivered to your door")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 60)
            
            // Toggle between Login and Sign Up
            Picker("Authentication", selection: $isSignUp) {
                Text("Sign In").tag(false)
                Text("Sign Up").tag(true)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal, horizontalSizeClass == .compact ? 40 : 80)
        }
    }
    
    // MARK: - Form View
    private var formView: some View {
        VStack(spacing: 20) {
            if isSignUp {
                signUpForm
            } else {
                signInForm
            }
        }
    }
    
    // MARK: - Sign In Form
    private var signInForm: some View {
        VStack(spacing: 20) {
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                    } else {
                        SecureField("Enter your password", text: $password)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Remember Me
            HStack {
                Toggle("Remember me", isOn: $rememberMe)
                    .font(.subheadline)
                Spacer()
            }
            
            // Sign In Button
            Button(action: {
                Task {
                    await appViewModel.login(email: email, password: password)
                }
            }) {
                HStack {
                    if appViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(appViewModel.isLoading || email.isEmpty || password.isEmpty)
            .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Sign Up Form
    private var signUpForm: some View {
        VStack(spacing: 20) {
            // Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Full Name")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "person")
                        .foregroundColor(.gray)
                    TextField("Enter your full name", text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Email Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Email")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "envelope")
                        .foregroundColor(.gray)
                    TextField("Enter your email", text: $email)
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "lock")
                        .foregroundColor(.gray)
                    
                    if showPassword {
                        TextField("Enter your password", text: $password)
                            .textFieldStyle(PlainTextFieldStyle())
                    } else {
                        SecureField("Enter your password", text: $password)
                    }
                    
                    Button(action: {
                        showPassword.toggle()
                    }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Phone Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Phone Number")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "phone")
                        .foregroundColor(.gray)
                    TextField("Enter your phone number", text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                        .keyboardType(.phonePad)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Address Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Delivery Address")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "location")
                        .foregroundColor(.gray)
                    TextField("Enter your delivery address", text: .constant(""))
                        .textFieldStyle(PlainTextFieldStyle())
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            
            // Sign Up Button
            Button(action: {
                // Handle sign up
            }) {
                HStack {
                    if appViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Text("Sign Up")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.orange)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .disabled(appViewModel.isLoading)
            .opacity(appViewModel.isLoading ? 0.6 : 1.0)
        }
    }
    
    // MARK: - Footer View
    private var footerView: some View {
        VStack(spacing: 15) {
            if !isSignUp {
                Button("Forgot Password?") {
                    // Handle forgot password
                }
                .font(.subheadline)
                .foregroundColor(.orange)
            }
            
            HStack {
                Text(isSignUp ? "Already have an account?" : "Don't have an account?")
                    .foregroundColor(.secondary)
                
                Button(isSignUp ? "Sign In" : "Sign Up") {
                    isSignUp.toggle()
                }
                .foregroundColor(.orange)
                .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AppViewModel())
} 
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Заголовок
                    VStack(spacing: 8) {
                        Text("Вхід в акаунт")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Увійдіть для доступу до вашого облікового запису")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    // Поля для входу
                    VStack(spacing: 16) {
                        // Email
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Email")
                                .font(.system(size: 16, weight: .medium))
                            
                            TextField("Введіть ваш email", text: $email)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                        
                        // Пароль
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Пароль")
                                .font(.system(size: 16, weight: .medium))
                            
                            SecureField("Введіть ваш пароль", text: $password)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Кнопка входу
                    Button(action: {
                        authViewModel.signIn(email: email, password: password)
                        hideKeyboard()
                    }) {
                        if authViewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("Увійти")
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .disabled(authViewModel.isLoading)
                    
                    // Помилка
                    if let error = authViewModel.error {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.system(size: 14))
                    }
                    
                    // Розділювач
                    HStack {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                        
                        Text("або")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                            .padding(.horizontal, 10)
                        
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 10)
                    
                    // Вхід через Google
                    Button(action: {
                        authViewModel.signInWithGoogle()
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                                .font(.system(size: 20))
                            Text("Увійти через Google")
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.black)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(authViewModel.isLoading)
                    
                    Spacer(minLength: 30)
                    
                    // Посилання на реєстрацію
                    HStack {
                        Text("Ще не маєте акаунта?")
                            .foregroundColor(.gray)
                        
                        Button(action: {
                            hideKeyboard()
                            showSignUp = true
                        }) {
                            Text("Зареєструватися")
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.bottom, 20)
                }
                .padding(.bottom, keyboardHeight)
            }
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
                if isAuthenticated {
                    dismiss()
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        hideKeyboard()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 17))
                            .foregroundColor(.gray)
                            .frame(width: 36, height: 36)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
            }
            .onTapGesture {
                hideKeyboard()
            }
            .onAppear {
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                    if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                        keyboardHeight = keyboardSize.height - 30 // Віднімаємо відступ для кращого вигляду
                    }
                }
                
                NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
                    keyboardHeight = 0
                }
            }
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
} 
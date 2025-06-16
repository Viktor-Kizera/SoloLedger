import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var businessType = "ФОП, 3 група"
    @State private var keyboardHeight: CGFloat = 0
    
    let businessTypes = ["ФОП, 1 група", "ФОП, 2 група", "ФОП, 3 група", "ТОВ"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Заголовок
                VStack(spacing: 8) {
                    Text("Створення акаунта")
                        .font(.system(size: 28, weight: .bold))
                    
                    Text("Заповніть дані для створення облікового запису")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 20)
                .padding(.bottom, 20)
                
                // Поля для реєстрації
                VStack(spacing: 16) {
                    // Ім'я
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Ім'я та прізвище")
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Введіть ваше ім'я", text: $name)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
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
                        
                        SecureField("Створіть пароль", text: $password)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Підтвердження пароля
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Підтвердження пароля")
                            .font(.system(size: 16, weight: .medium))
                        
                        SecureField("Повторіть пароль", text: $confirmPassword)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    
                    // Тип бізнесу
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Тип бізнесу")
                            .font(.system(size: 16, weight: .medium))
                        
                        HStack {
                            Text("Тип")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Menu {
                                ForEach(businessTypes, id: \.self) { type in
                                    Button(action: {
                                        businessType = type
                                    }) {
                                        Text(type)
                                    }
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Text(businessType)
                                        .font(.system(size: 16))
                                        .foregroundColor(.blue)
                                    
                                    Image(systemName: "chevron.down")
                                        .font(.system(size: 14))
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                }
                .padding(.horizontal)
                
                // Кнопка реєстрації
                Button(action: {
                    if isFormValid {
                        hideKeyboard()
                        authViewModel.signUp(
                            name: name,
                            email: email,
                            password: password,
                            businessType: businessType
                        )
                    }
                }) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Зареєструватися")
                            .font(.system(size: 18, weight: .semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(isFormValid ? Color.blue : Color.gray)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 20)
                .disabled(!isFormValid || authViewModel.isLoading)
                
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
                
                // Посилання на вхід
                HStack {
                    Text("Вже маєте акаунт?")
                        .foregroundColor(.gray)
                    
                    Button(action: {
                        hideKeyboard()
                        dismiss()
                    }) {
                        Text("Увійти")
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.bottom, 20)
                .padding(.top, 10)
            }
            .padding(.horizontal)
            .padding(.bottom, keyboardHeight)
        }
        .navigationBarBackButtonHidden(true)
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
        .onChange(of: authViewModel.isAuthenticated) { isAuthenticated in
            if isAuthenticated {
                // Закриваємо екран реєстрації і повертаємося на попередній екран
                dismiss()
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
    
    // Валідація форми
    var isFormValid: Bool {
        !name.isEmpty && 
        !email.isEmpty && email.contains("@") &&
        password.count >= 6 &&
        password == confirmPassword
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
} 
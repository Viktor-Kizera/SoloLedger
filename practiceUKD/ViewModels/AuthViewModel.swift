import SwiftUI
import Combine

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    // Ключ для збереження всіх користувачів
    private let usersKey = "registeredUsers"
    
    // Ініціалізація та перевірка збереженого користувача
    init() {
        // Перевіряємо, чи є збережений поточний користувач
        if let userData = UserDefaults.standard.data(forKey: "currentUser") {
            let decoder = JSONDecoder()
            if let savedUser = try? decoder.decode(User.self, from: userData) {
                self.currentUser = savedUser
                self.isAuthenticated = true
            }
        }
        
        // Виконуємо міграцію існуючих користувачів
        migrateExistingUsers()
    }
    
    // Міграція існуючих користувачів для додавання хешів паролів
    private func migrateExistingUsers() {
        var users = getRegisteredUsers()
        var updated = false
        
        // Для кожного користувача без хешу пароля додаємо стандартний пароль "password"
        for i in 0..<users.count {
            if users[i].passwordHash == nil {
                users[i].passwordHash = User.hashPassword("password")
                updated = true
            }
        }
        
        // Зберігаємо оновлених користувачів
        if updated {
            saveRegisteredUsers(users)
        }
    }
    
    // Вхід через email та пароль
    func signIn(email: String, password: String) {
        isLoading = true
        error = nil
        
        // Отримуємо збережених користувачів
        let users = getRegisteredUsers()
        
        // Хешуємо введений пароль для порівняння
        let hashedPassword = User.hashPassword(password)
        
        // Симуляція мережевого запиту
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Перевіряємо тестові дані для демонстрації
            if email == "test@example.com" && password == "password" {
                let user = User(
                    id: "user123",
                    name: "Олександр Шевченко",
                    email: email,
                    passwordHash: hashedPassword
                )
                self.currentUser = user
                self.isAuthenticated = true
                self.saveUserToDefaults(user: user)
            } 
            // Перевіряємо серед зареєстрованих користувачів
            else if let user = users.first(where: { $0.email.lowercased() == email.lowercased() }) {
                // Перевіряємо пароль
                if let storedHash = user.passwordHash, storedHash == hashedPassword {
                    self.currentUser = user
                    self.isAuthenticated = true
                    self.saveUserToDefaults(user: user)
                } else {
                    self.error = "Невірний пароль"
                }
            } else {
                self.error = "Користувач з таким email не знайдений"
            }
            
            self.isLoading = false
        }
    }
    
    // Реєстрація нового користувача
    func signUp(name: String, email: String, password: String, businessType: String) {
        isLoading = true
        error = nil
        
        // Отримуємо збережених користувачів
        var users = getRegisteredUsers()
        
        // Перевіряємо, чи вже є користувач з таким email
        if users.contains(where: { $0.email.lowercased() == email.lowercased() }) {
            error = "Користувач з таким email вже існує"
            isLoading = false
            return
        }
        
        // Хешуємо пароль перед збереженням
        let hashedPassword = User.hashPassword(password)
        
        // Симуляція мережевого запиту
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Тут буде реальна логіка реєстрації через API
            
            // Для демонстрації створюємо користувача
            let user = User(
                id: UUID().uuidString,
                name: name,
                email: email,
                businessType: businessType,
                passwordHash: hashedPassword
            )
            
            // Додаємо користувача до списку зареєстрованих
            users.append(user)
            self.saveRegisteredUsers(users)
            
            // Встановлюємо поточного користувача
            self.currentUser = user
            self.isAuthenticated = true
            self.saveUserToDefaults(user: user)
            self.isLoading = false
        }
    }
    
    // Вхід через Google
    func signInWithGoogle() {
        isLoading = true
        error = nil
        
        // Симуляція мережевого запиту
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            // Тут буде реальна логіка аутентифікації через Google
            
            // Для демонстрації створюємо користувача
            let user = User(
                id: "google_user_123",
                name: "Google User",
                email: "google@example.com",
                photoURL: "https://example.com/photo.jpg"
            )
            
            // Додаємо користувача до списку зареєстрованих, якщо його ще немає
            var users = self.getRegisteredUsers()
            if !users.contains(where: { $0.email == user.email }) {
                users.append(user)
                self.saveRegisteredUsers(users)
            }
            
            self.currentUser = user
            self.isAuthenticated = true
            self.saveUserToDefaults(user: user)
            self.isLoading = false
        }
    }
    
    // Вихід з акаунта
    func signOut() {
        isLoading = true
        
        // Симуляція мережевого запиту
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Тут буде реальна логіка виходу з акаунта
            
            self.currentUser = nil
            self.isAuthenticated = false
            UserDefaults.standard.removeObject(forKey: "currentUser")
            self.isLoading = false
        }
    }
    
    // Збереження поточного користувача в UserDefaults
    private func saveUserToDefaults(user: User) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }
    
    // Отримання списку зареєстрованих користувачів
    private func getRegisteredUsers() -> [User] {
        if let data = UserDefaults.standard.data(forKey: usersKey),
           let users = try? JSONDecoder().decode([User].self, from: data) {
            return users
        }
        return []
    }
    
    // Збереження списку зареєстрованих користувачів
    private func saveRegisteredUsers(_ users: [User]) {
        if let encoded = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(encoded, forKey: usersKey)
        }
    }
} 
import SwiftUI
import CryptoKit

struct User: Identifiable, Codable {
    var id: String
    var name: String
    var email: String
    var businessType: String
    var photoURL: String?
    var passwordHash: String?
    
    init(id: String, name: String, email: String, businessType: String = "ФОП, 3 група", photoURL: String? = nil, passwordHash: String? = nil) {
        self.id = id
        self.name = name
        self.email = email
        self.businessType = businessType
        self.photoURL = photoURL
        self.passwordHash = passwordHash
    }
    
    // Функція для хешування пароля
    static func hashPassword(_ password: String) -> String {
        let inputData = Data(password.utf8)
        let hashed = SHA256.hash(data: inputData)
        return hashed.compactMap { String(format: "%02x", $0) }.joined()
    }
}

// Модель транзакції
struct TransactionModel: Identifiable, Codable {
    var id: String
    var title: String
    var amount: Double
    var date: Date
    var isIncome: Bool
    var category: TransactionCategoryModel
    var note: String?
    var userId: String // ID користувача, якому належить транзакція
    
    init(id: String = UUID().uuidString, 
         title: String, 
         amount: Double, 
         date: Date = Date(), 
         isIncome: Bool, 
         category: TransactionCategoryModel, 
         note: String? = nil,
         userId: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.isIncome = isIncome
        self.category = category
        self.note = note
        self.userId = userId
    }
    
    // Отримати форматовану дату
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: date)
    }
    
    // Отримати форматовану суму
    func formattedAmount() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        let formattedAmount = formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
        return isIncome ? "+₴\(formattedAmount)" : "-₴\(formattedAmount)"
    }
}

// Модель категорії транзакції
struct TransactionCategoryModel: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var icon: String
    var colorHex: String // Зберігаємо колір як HEX-код
    
    init(id: String = UUID().uuidString, 
         name: String, 
         icon: String, 
         colorHex: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }
    
    // Отримати Color з HEX-коду або назви кольору
    func getColor() -> Color {
        // Спочатку перевіряємо, чи це назва кольору
        switch colorHex.lowercased() {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "gray": return .gray
        default:
            // Якщо не назва, то пробуємо як HEX-код
            if colorHex.hasPrefix("#") {
                let hex = colorHex.dropFirst()
                var rgbValue: UInt64 = 0
                Scanner(string: String(hex)).scanHexInt64(&rgbValue)
                
                let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
                let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
                let blue = Double(rgbValue & 0x0000FF) / 255.0
                
                return Color(red: red, green: green, blue: blue)
            }
            // Якщо не вдалося розпізнати, повертаємо синій
            return .blue
        }
    }
    
    // Перевірка на рівність
    static func == (lhs: TransactionCategoryModel, rhs: TransactionCategoryModel) -> Bool {
        return lhs.id == rhs.id
    }
} 
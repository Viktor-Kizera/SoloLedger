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
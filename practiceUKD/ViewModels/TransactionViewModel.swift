import SwiftUI
import Combine

class TransactionViewModel: ObservableObject {
    @Published var transactions: [TransactionModel] = []
    @Published var categories: [TransactionCategoryModel] = []
    
    // Ключі для UserDefaults
    private let transactionsKey = "userTransactions"
    private let categoriesKey = "userCategories"
    
    // Ініціалізація
    init() {
        // Створюємо стандартні категорії
        createDefaultCategories()
        
        // Завантажуємо користувацькі категорії
        loadCategories()
        
        // Завантажуємо транзакції
        loadTransactions()
    }
    
    // Створення стандартних категорій
    private func createDefaultCategories() {
        let defaultCategories = [
            // Категорії доходів
            TransactionCategoryModel(name: "Розробка", icon: "💻", colorHex: "#4CAF50"),
            TransactionCategoryModel(name: "Дизайн", icon: "🎨", colorHex: "#2196F3"),
            TransactionCategoryModel(name: "Консультація", icon: "📊", colorHex: "#9C27B0"),
            TransactionCategoryModel(name: "Маркетинг", icon: "📣", colorHex: "#FFC107"),
            TransactionCategoryModel(name: "Продажі", icon: "💰", colorHex: "#FF9800"),
            TransactionCategoryModel(name: "Інвестиції", icon: "📈", colorHex: "#4CAF50"),
            TransactionCategoryModel(name: "Фріланс", icon: "👨‍💻", colorHex: "#2196F3"),
            TransactionCategoryModel(name: "Оренда", icon: "🏠", colorHex: "#9C27B0"),
            
            // Категорії витрат
            TransactionCategoryModel(name: "Їжа", icon: "🍔", colorHex: "#FF5252"),
            TransactionCategoryModel(name: "Транспорт", icon: "🚗", colorHex: "#FF9800"),
            TransactionCategoryModel(name: "Житло", icon: "🏠", colorHex: "#2196F3"),
            TransactionCategoryModel(name: "Розваги", icon: "🎬", colorHex: "#9C27B0"),
            TransactionCategoryModel(name: "Здоров'я", icon: "💊", colorHex: "#4CAF50"),
            TransactionCategoryModel(name: "Одяг", icon: "👕", colorHex: "#E91E63"),
            TransactionCategoryModel(name: "Техніка", icon: "📱", colorHex: "#607D8B"),
            TransactionCategoryModel(name: "Подарунки", icon: "🎁", colorHex: "#FF5252"),
            TransactionCategoryModel(name: "Освіта", icon: "📚", colorHex: "#2196F3"),
            TransactionCategoryModel(name: "Податки", icon: "📝", colorHex: "#607D8B"),
            TransactionCategoryModel(name: "Інше", icon: "❓", colorHex: "#607D8B")
        ]
        
        // Перевіряємо, чи вже є категорії, якщо немає - додаємо стандартні
        if categories.isEmpty {
            categories = defaultCategories
            saveCategories()
        }
    }
    
    // Завантаження категорій
    private func loadCategories() {
        if let data = UserDefaults.standard.data(forKey: categoriesKey),
           let savedCategories = try? JSONDecoder().decode([TransactionCategoryModel].self, from: data) {
            categories = savedCategories
        }
    }
    
    // Збереження категорій
    private func saveCategories() {
        if let encoded = try? JSONEncoder().encode(categories) {
            UserDefaults.standard.set(encoded, forKey: categoriesKey)
        }
    }
    
    // Додавання нової категорії
    func addCategory(name: String, icon: String, colorHex: String) {
        let newCategory = TransactionCategoryModel(
            name: name,
            icon: icon,
            colorHex: colorHex
        )
        
        categories.append(newCategory)
        saveCategories()
    }
    
    // Видалення категорії
    func deleteCategory(at index: Int) {
        guard index < categories.count else { return }
        categories.remove(at: index)
        saveCategories()
    }
    
    // Отримання всіх категорій
    func getAllCategories() -> [TransactionCategoryModel] {
        return categories
    }
    
    // Завантаження транзакцій
    private func loadTransactions() {
        if let data = UserDefaults.standard.data(forKey: transactionsKey),
           let savedTransactions = try? JSONDecoder().decode([TransactionModel].self, from: data) {
            transactions = savedTransactions
        }
    }
    
    // Збереження транзакцій
    private func saveTransactions() {
        if let encoded = try? JSONEncoder().encode(transactions) {
            UserDefaults.standard.set(encoded, forKey: transactionsKey)
        }
    }
    
    // Додавання нової транзакції
    func addTransaction(title: String, amount: Double, date: Date, isIncome: Bool, category: TransactionCategoryModel, note: String?, userId: String) {
        let newTransaction = TransactionModel(
            title: title,
            amount: amount,
            date: date,
            isIncome: isIncome,
            category: category,
            note: note,
            userId: userId
        )
        
        transactions.append(newTransaction)
        saveTransactions()
    }
    
    // Видалення транзакції
    func deleteTransaction(at index: Int) {
        guard index < transactions.count else { return }
        transactions.remove(at: index)
        saveTransactions()
    }
    
    // Отримання транзакцій користувача
    func getUserTransactions(userId: String) -> [TransactionModel] {
        return transactions.filter { $0.userId == userId }
    }
    
    // Отримання транзакцій за типом (дохід/витрата)
    func getTransactionsByType(userId: String, isIncome: Bool) -> [TransactionModel] {
        return transactions.filter { $0.userId == userId && $0.isIncome == isIncome }
    }
    
    // Отримання транзакцій за місяцем
    func getTransactionsForCurrentMonth(userId: String) -> [TransactionModel] {
        let calendar = Calendar.current
        let now = Date()
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        return transactions.filter { transaction in
            transaction.userId == userId &&
            transaction.date >= startOfMonth &&
            transaction.date <= endOfMonth
        }
    }
    
    // Групування транзакцій за датою
    func groupTransactionsByDate(transactions: [TransactionModel]) -> [String: [TransactionModel]] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "d MMMM, yyyy"
        
        var grouped = [String: [TransactionModel]]()
        
        for transaction in transactions {
            let dateString = formatter.string(from: transaction.date)
            if grouped[dateString] == nil {
                grouped[dateString] = [transaction]
            } else {
                grouped[dateString]?.append(transaction)
            }
        }
        
        return grouped
    }
    
    // Отримання загальної суми доходів
    func getTotalIncome(userId: String) -> Double {
        return transactions
            .filter { $0.userId == userId && $0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Отримання загальної суми витрат
    func getTotalExpense(userId: String) -> Double {
        return transactions
            .filter { $0.userId == userId && !$0.isIncome }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Отримання поточного балансу
    func getCurrentBalance(userId: String) -> Double {
        let income = getTotalIncome(userId: userId)
        let expense = getTotalExpense(userId: userId)
        return income - expense
    }
} 
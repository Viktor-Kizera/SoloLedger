import SwiftUI

struct TransactionsView: View {
    @State private var selectedFilter: TransactionFilter = .all
    
    // Спрощені дані для транзакцій
    let transactionGroups: [TransactionGroup] = [
        TransactionGroup(
            title: "Сьогодні",
            totalAmount: 12150,
            transactions: [
                Transaction(title: "Розробка веб-сайту", date: "14 червня, 2023", amount: 12500, isIncome: true, category: "development"),
                Transaction(title: "Обід", date: "14 червня, 2023", amount: 350, isIncome: false, category: "food")
            ]
        ),
        TransactionGroup(
            title: "Вчора",
            totalAmount: 4500,
            transactions: [
                Transaction(title: "Консультація", date: "13 червня, 2023", amount: 4500, isIncome: true, category: "consulting")
            ]
        ),
        TransactionGroup(
            title: "12 червня",
            totalAmount: 10700,
            transactions: [
                Transaction(title: "Дизайн логотипу", date: "12 червня, 2023", amount: 8200, isIncome: true, category: "design"),
                Transaction(title: "Інтернет", date: "12 червня, 2023", amount: 500, isIncome: false, category: "internet")
            ]
        )
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Заголовок
                HStack {
                    Text("Транзакції")
                        .font(.system(size: 28, weight: .bold))
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "line.3.horizontal.decrease")
                            .foregroundColor(.blue)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                
                // Фільтри
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        FilterButton(title: "Усі", isSelected: selectedFilter == .all) {
                            selectedFilter = .all
                        }
                        FilterButton(title: "Дохід", isSelected: selectedFilter == .income) {
                            selectedFilter = .income
                        }
                        FilterButton(title: "Витрати", isSelected: selectedFilter == .expense) {
                            selectedFilter = .expense
                        }
                        FilterButton(title: "Цей місяць", isSelected: selectedFilter == .thisMonth) {
                            selectedFilter = .thisMonth
                        }
                    }
                }
                
                // Список транзакцій по групах
                ForEach(transactionGroups, id: \.id) { group in
                    VStack(alignment: .leading, spacing: 12) {
                        // Заголовок дати та сума
                        HStack {
                            Text(group.title)
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.gray)
                            Spacer()
                            Text("₴\(formatAmount(group.totalAmount))")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        
                        // Транзакції за цю дату
                        ForEach(group.transactions, id: \.id) { transaction in
                            TransactionRowView(transaction: transaction)
                        }
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
            .background(Color(.systemGroupedBackground))
        }
    }
    
    // Функція для форматування суми
    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
}

enum TransactionFilter {
    case all, income, expense, thisMonth
}

struct TransactionGroup: Identifiable {
    let id = UUID()
    let title: String
    let totalAmount: Double
    let transactions: [Transaction]
}

struct Transaction: Identifiable {
    let id = UUID()
    let title: String
    let date: String
    let amount: Double
    let isIncome: Bool
    let category: String
}

struct TransactionRowView: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 14) {
            // Іконка категорії
            ZStack {
                Circle()
                    .fill(categoryColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: categoryIcon)
                    .foregroundColor(categoryColor)
                    .font(.system(size: 20, weight: .bold))
            }
            
            // Назва та дата
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(transaction.date)
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            // Сума
            Text(amountText)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.isIncome ? .green : .red)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
    
    // Колір для категорії
    var categoryColor: Color {
        switch transaction.category {
        case "development": return .green
        case "food": return .red
        case "consulting": return .blue
        case "design": return .yellow
        case "internet": return .purple
        default: return .gray
        }
    }
    
    // Іконка для категорії
    var categoryIcon: String {
        switch transaction.category {
        case "development": return "bag.fill"
        case "food": return "fork.knife"
        case "consulting": return "creditcard"
        case "design": return "pencil"
        case "internet": return "wifi"
        default: return "circle"
        }
    }
    
    // Текст для суми
    var amountText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        let formattedAmount = formatter.string(from: NSNumber(value: transaction.amount)) ?? "\(transaction.amount)"
        return transaction.isIncome ? "+₴\(formattedAmount)" : "-₴\(formattedAmount)"
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Capsule()
                        .fill(isSelected ? Color.blue : Color.gray.opacity(0.15))
                )
                .foregroundColor(isSelected ? .white : .black)
        }
    }
}

#Preview {
    TransactionsView()
} 
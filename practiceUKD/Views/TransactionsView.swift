import SwiftUI

struct TransactionsView: View {
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedFilter: TransactionFilter = .all
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
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
                    
                    if let userId = authViewModel.currentUser?.id {
                        // Отримуємо транзакції відповідно до фільтра
                        let filteredTransactions: [TransactionModel] = {
                            switch selectedFilter {
                            case .all:
                                return transactionViewModel.getUserTransactions(userId: userId)
                            case .income:
                                return transactionViewModel.getTransactionsByType(userId: userId, isIncome: true)
                            case .expense:
                                return transactionViewModel.getTransactionsByType(userId: userId, isIncome: false)
                            case .thisMonth:
                                return transactionViewModel.getTransactionsForCurrentMonth(userId: userId)
                            }
                        }()
                        
                        if filteredTransactions.isEmpty {
                            // Показуємо повідомлення, якщо немає транзакцій
                            VStack(spacing: 20) {
                                Image(systemName: "doc.text.magnifyingglass")
                                    .font(.system(size: 60))
                                    .foregroundColor(.gray)
                                Text("Немає транзакцій")
                                    .font(.title2)
                                    .foregroundColor(.gray)
                                Text("Додайте свою першу транзакцію, натиснувши на кнопку '+' внизу екрану")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 50)
                        } else {
                            // Групуємо транзакції за датою
                            let groupedTransactions = transactionViewModel.groupTransactionsByDate(transactions: filteredTransactions)
                            let sortedDates = groupedTransactions.keys.sorted { date1, date2 in
                                // Сортуємо дати у зворотньому порядку (нові спочатку)
                                let formatter = DateFormatter()
                                formatter.locale = Locale(identifier: "uk_UA")
                                formatter.dateFormat = "d MMMM, yyyy"
                                guard let date1Date = formatter.date(from: date1),
                                      let date2Date = formatter.date(from: date2) else {
                                    return date1 > date2 // Сортуємо за рядками, якщо не вдалося перетворити
                                }
                                return date1Date > date2Date
                            }
                            
                            ForEach(sortedDates, id: \.self) { dateString in
                                if let transactions = groupedTransactions[dateString] {
                                    VStack(alignment: .leading, spacing: 12) {
                                        // Заголовок дати та сума
                                        HStack {
                                            Text(formatDateHeader(dateString))
                                                .font(.system(size: 18, weight: .medium))
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text(formatTotalAmount(transactions))
                                                .font(.system(size: 18, weight: .semibold))
                                        }
                                        
                                        // Транзакції за цю дату
                                        ForEach(transactions) { transaction in
                                            TransactionRowView(transaction: transaction)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        // Користувач не авторизований
                        VStack(spacing: 20) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Увійдіть в акаунт")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Щоб переглядати транзакції, необхідно увійти в акаунт або зареєструватися")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
        }
    }
    
    // Форматування заголовка дати (сьогодні, вчора, або дата)
    private func formatDateHeader(_ dateString: String) -> String {
        let today = formatDate(Date())
        let yesterday = formatDate(Calendar.current.date(byAdding: .day, value: -1, to: Date())!)
        
        if dateString == today {
            return "Сьогодні"
        } else if dateString == yesterday {
            return "Вчора"
        } else {
            return dateString
        }
    }
    
    // Форматування дати
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: date)
    }
    
    // Форматування загальної суми
    private func formatTotalAmount(_ transactions: [TransactionModel]) -> String {
        let total = transactions.reduce(0) { sum, transaction in
            transaction.isIncome ? sum + transaction.amount : sum - transaction.amount
        }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        
        let formattedAmount = formatter.string(from: NSNumber(value: abs(total))) ?? "\(abs(total))"
        return total >= 0 ? "+₴\(formattedAmount)" : "-₴\(formattedAmount)"
    }
}

enum TransactionFilter {
    case all, income, expense, thisMonth
}

struct TransactionRowView: View {
    let transaction: TransactionModel
    
    var body: some View {
        HStack(spacing: 14) {
            // Іконка категорії
            ZStack {
                Circle()
                    .fill(transaction.category.getColor().opacity(0.15))
                    .frame(width: 44, height: 44)
                Text(transaction.category.icon)
                    .font(.system(size: 20))
            }
            
            // Назва та дата
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.title)
                    .font(.system(size: 16, weight: .semibold))
                Text(transaction.formattedDate())
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                
                // Примітка (якщо є)
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.system(size: 12))
                        .foregroundColor(.gray.opacity(0.8))
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Сума
            Text(transaction.formattedAmount())
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(transaction.isIncome ? .green : .red)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
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
        .environmentObject(TransactionViewModel())
        .environmentObject(AuthViewModel())
} 
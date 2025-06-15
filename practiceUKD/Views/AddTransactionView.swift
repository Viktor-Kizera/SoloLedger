import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var transactionType: TransactionType = .income
    @State private var amount: String = "0.00"
    @State private var selectedCategory: String?
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    let categories: [TransactionCategory] = [
        TransactionCategory(name: "Розробка", icon: "</> ", color: .green),
        TransactionCategory(name: "Дизайн", icon: "✏️", color: .blue),
        TransactionCategory(name: "Маркетинг", icon: "📣", color: .yellow),
        TransactionCategory(name: "Інше", icon: "+", color: .gray)
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Заголовок з кнопкою назад
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.blue)
                            Text("Нова транзакція")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(.black)
                        }
                    }
                    Spacer()
                }
                
                // Перемикач типу транзакції
                HStack(spacing: 0) {
                    Button(action: { transactionType = .income }) {
                        Text("Дохід")
                            .font(.system(size: 18, weight: transactionType == .income ? .semibold : .regular))
                            .foregroundColor(transactionType == .income ? .black : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(transactionType == .income ? Color.white : Color.clear)
                            )
                    }
                    
                    Button(action: { transactionType = .expense }) {
                        Text("Витрата")
                            .font(.system(size: 18, weight: transactionType == .expense ? .semibold : .regular))
                            .foregroundColor(transactionType == .expense ? .black : .gray)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(transactionType == .expense ? Color.white : Color.clear)
                            )
                    }
                }
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
                
                // Сума
                VStack(alignment: .leading, spacing: 12) {
                    Text("Сума")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Text("₴")
                            .font(.system(size: 36, weight: .bold))
                        TextField("0.00", text: $amount)
                            .font(.system(size: 36, weight: .bold))
                            .keyboardType(.decimalPad)
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Категорія
                VStack(alignment: .leading, spacing: 12) {
                    Text("Категорія")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                        ForEach(categories) { category in
                            CategoryButton(
                                category: category,
                                isSelected: selectedCategory == category.name,
                                action: { selectedCategory = category.name }
                            )
                        }
                    }
                }
                
                // Дата
                VStack(alignment: .leading, spacing: 12) {
                    Text("Дата")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.gray)
                        Text("14 червня, 2023")
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Примітка
                VStack(alignment: .leading, spacing: 12) {
                    Text("Примітка")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.gray)
                    
                    HStack {
                        Image(systemName: "square.and.pencil")
                            .foregroundColor(.gray)
                        Text("Додайте примітку...")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                }
                
                // Кнопка Зберегти
                Button(action: {
                    // Логіка збереження транзакції
                }) {
                    Text("Зберегти")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.top, 16)
                .padding(.bottom, 120)
            }
            .padding(20)
            .background(Color(.systemGroupedBackground))
        }
        .navigationBarHidden(true)
    }
}

enum TransactionType {
    case income, expense
}

struct TransactionCategory: Identifiable {
    var id = UUID()
    var name: String
    var icon: String
    var color: Color
}

struct CategoryButton: View {
    var category: TransactionCategory
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    Text(category.icon)
                        .font(.system(size: 24))
                }
                .overlay(
                    Circle()
                        .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
                )
                
                Text(category.name)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
            }
        }
    }
}

#Preview {
    AddTransactionView()
} 
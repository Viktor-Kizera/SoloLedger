import SwiftUI

struct AddTransactionView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var transactionType: TransactionType = .income
    @State private var amount: String = ""
    @State private var title: String = ""
    @State private var selectedCategory: TransactionCategoryModel?
    @State private var date: Date = Date()
    @State private var note: String = ""
    
    // Стани для створення нової категорії
    @State private var isShowingNewCategorySheet = false
    @State private var newCategoryName = ""
    @State private var newCategoryIcon = "❓"
    @State private var newCategoryColor = "blue"
    
    // Стани для сповіщень
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var showSuccessToast = false
    
    // Доступні кольори
    let availableColors = ["red", "green", "blue", "yellow", "purple", "orange", "pink", "gray"]
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
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
                    
                    // Назва транзакції
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Назва")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextField("Введіть назву транзакції", text: $title)
                            .font(.system(size: 18))
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
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
                        HStack {
                            Text("Категорія")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Button(action: {
                                isShowingNewCategorySheet = true
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 14))
                                    Text("Створити")
                                        .font(.system(size: 14))
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        // Відображення категорій у сітці
                        let categories = transactionViewModel.getAllCategories()
                            .filter { transactionType == .income ? !["Їжа", "Транспорт", "Житло", "Розваги", "Здоров'я", "Одяг", "Техніка", "Подарунки", "Освіта", "Податки"].contains($0.name) : 
                                                                  !["Розробка", "Дизайн", "Консультація", "Маркетинг", "Продажі", "Інвестиції", "Фріланс", "Оренда"].contains($0.name) }
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHGrid(rows: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                                ForEach(categories) { category in
                                    CategoryButton(
                                        category: category,
                                        isSelected: selectedCategory?.id == category.id,
                                        action: { selectedCategory = category }
                                    )
                                }
                            }
                            .frame(height: 180)
                        }
                    }
                    
                    // Дата
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Дата")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        
                        DatePicker("", selection: $date, displayedComponents: [.date])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                    }
                    
                    // Примітка
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Примітка")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                        
                        TextEditor(text: $note)
                            .frame(height: 100)
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                    }
                    
                    // Кнопка Зберегти
                    Button(action: saveTransaction) {
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
            }
            
            // Сповіщення про успішне збереження
            if showSuccessToast {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 24))
                        
                        Text("Транзакцію успішно збережено")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.3), value: showSuccessToast)
                .zIndex(1)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $isShowingNewCategorySheet) {
            createNewCategoryView()
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Помилка"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
    
    // Функція для збереження транзакції
    private func saveTransaction() {
        guard let userId = authViewModel.currentUser?.id else {
            alertMessage = "Ви не авторизовані"
            showAlert = true
            return
        }
        
        guard !title.isEmpty else {
            alertMessage = "Введіть назву транзакції"
            showAlert = true
            return
        }
        
        guard let amountValue = Double(amount.replacingOccurrences(of: ",", with: ".")) else {
            alertMessage = "Введіть коректну суму"
            showAlert = true
            return
        }
        
        guard let category = selectedCategory else {
            alertMessage = "Виберіть категорію"
            showAlert = true
            return
        }
        
        // Додаємо транзакцію
        transactionViewModel.addTransaction(
            title: title,
            amount: amountValue,
            date: date,
            isIncome: transactionType == .income,
            category: category,
            note: note.isEmpty ? nil : note,
            userId: userId
        )
        
        // Показуємо сповіщення про успіх
        showSuccessToast = true
        
        // Скидаємо форму
        resetForm()
        
        // Приховуємо сповіщення через 2 секунди
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showSuccessToast = false
            }
        }
    }
    
    // Функція для скидання форми
    private func resetForm() {
        transactionType = .income
        title = ""
        amount = ""
        selectedCategory = nil
        date = Date()
        note = ""
    }
    
    // Представлення для створення нової категорії
    private func createNewCategoryView() -> some View {
        NavigationView {
            Form {
                Section(header: Text("Інформація про категорію")) {
                    TextField("Назва категорії", text: $newCategoryName)
                    
                    HStack {
                        Text("Іконка")
                        Spacer()
                        EmojiPicker(selectedEmoji: $newCategoryIcon)
                    }
                    
                    Picker("Колір", selection: $newCategoryColor) {
                        ForEach(availableColors, id: \.self) { color in
                            HStack {
                                Circle()
                                    .fill(getColor(color))
                                    .frame(width: 20, height: 20)
                                Text(color.capitalized)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Нова категорія")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Скасувати") {
                        isShowingNewCategorySheet = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Зберегти") {
                        saveNewCategory()
                    }
                    .disabled(newCategoryName.isEmpty)
                }
            }
        }
    }
    
    // Функція для збереження нової категорії
    private func saveNewCategory() {
        // Конвертуємо назву кольору в HEX-код
        let colorHex = convertColorNameToHex(newCategoryColor)
        
        transactionViewModel.addCategory(
            name: newCategoryName,
            icon: newCategoryIcon,
            colorHex: colorHex
        )
        
        // Очищаємо поля
        newCategoryName = ""
        newCategoryIcon = "❓"
        newCategoryColor = "blue"
        
        isShowingNewCategorySheet = false
    }
    
    // Отримати колір з рядка
    private func getColor(_ colorName: String) -> Color {
        switch colorName {
        case "red": return .red
        case "green": return .green
        case "blue": return .blue
        case "yellow": return .yellow
        case "purple": return .purple
        case "orange": return .orange
        case "pink": return .pink
        case "gray": return .gray
        default: return .blue
        }
    }
    
    // Конвертація назви кольору в HEX-код
    private func convertColorNameToHex(_ colorName: String) -> String {
        switch colorName {
        case "red": return "#FF5252"
        case "green": return "#4CAF50"
        case "blue": return "#2196F3"
        case "yellow": return "#FFC107"
        case "purple": return "#9C27B0"
        case "orange": return "#FF9800"
        case "pink": return "#E91E63"
        case "gray": return "#607D8B"
        default: return "#2196F3" // Синій за замовчуванням
        }
    }
    
    // Приховати клавіатуру
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// Тип транзакції
enum TransactionType {
    case income, expense
}

// Кнопка категорії
struct CategoryButton: View {
    var category: TransactionCategoryModel
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(category.getColor().opacity(0.15))
                        .frame(width: 60, height: 60)
                    Text(category.icon)
                        .font(.system(size: 24))
                }
                .overlay(
                    Circle()
                        .stroke(isSelected ? category.getColor() : Color.clear, lineWidth: 2)
                )
                
                Text(category.name)
                    .font(.system(size: 14))
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(width: 80)
        }
    }
}

// Вибір емодзі
struct EmojiPicker: View {
    @Binding var selectedEmoji: String
    @State private var isShowingEmojiPicker = false
    
    // Популярні емодзі
    let emojis = ["💰", "💸", "💵", "💳", "🏠", "🚗", "🍔", "🛒", "🎬", "🎮", "📱", "💊", "📚", "✈️", 
                  "🎁", "👕", "⚽️", "🎵", "🍕", "☕️", "🍺", "🏋️‍♂️", "💇‍♀️", "🧘‍♂️", "🚕", "🚌", "🚂", "💻", 
                  "📊", "📈", "📉", "🧾", "📝", "🔧", "🔨", "🧰", "🧹", "🧼", "🧴", "👶", "👨‍👩‍👧‍👦", "❤️", "❓"]
    
    var body: some View {
        Button(action: {
            isShowingEmojiPicker.toggle()
        }) {
            Text(selectedEmoji)
                .font(.system(size: 30))
        }
        .sheet(isPresented: $isShowingEmojiPicker) {
            NavigationView {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: 10) {
                        ForEach(emojis, id: \.self) { emoji in
                            Button(action: {
                                selectedEmoji = emoji
                                isShowingEmojiPicker = false
                            }) {
                                Text(emoji)
                                    .font(.system(size: 30))
                                    .padding(10)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Виберіть емодзі")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Готово") {
                            isShowingEmojiPicker = false
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    AddTransactionView()
        .environmentObject(TransactionViewModel())
        .environmentObject(AuthViewModel())
} 
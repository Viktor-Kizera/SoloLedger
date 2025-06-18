import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @State private var selectedMonthIndex: Int = 0
    @State private var months: [Date] = []
    @State private var showMonthPicker = false
    @State private var selectedDate = Date()
    @State private var isCustomPeriod = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    // Дані для графіків
    @State private var incomeData: [(String, CGFloat)] = []
    @State private var expenseData: [(String, CGFloat)] = []
    @State private var expenseCategories: [(String, Double, Color)] = []
    
    // Загальні суми
    @State private var totalIncome: Double = 0
    @State private var totalExpense: Double = 0
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Заголовок
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Аналітика")
                                .font(.system(size: 28, weight: .bold))
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            showMonthPicker = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.15))
                                    .frame(width: 44, height: 44)
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 20, weight: .bold))
                            }
                        }
                        .sheet(isPresented: $showMonthPicker) {
                            MonthPickerView(
                                selectedDate: $selectedDate, 
                                isPresented: $showMonthPicker,
                                isRangePicker: $isCustomPeriod,
                                startDate: $startDate,
                                endDate: $endDate,
                                onSelect: { isRange in
                                    // Обробка вибору місяця або періоду
                                    if isRange {
                                        isCustomPeriod = true
                                        addCustomPeriod(start: startDate, end: endDate)
                                    } else {
                                        isCustomPeriod = false
                                        addCustomMonth(date: selectedDate)
                                    }
                                    updateAnalyticsData()
                                }
                            )
                        }
                    }
                    
                    // Селектор місяців
                    VStack(alignment: .leading, spacing: 8) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(0..<months.count, id: \.self) { index in
                                    Button(action: {
                                        selectedMonthIndex = index
                                        isCustomPeriod = false
                                        updateAnalyticsData()
                                    }) {
                                        Text(formatMonth(months[index]))
                                            .font(.system(size: 16, weight: .medium))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(
                                                Capsule()
                                                    .fill(selectedMonthIndex == index && !isCustomPeriod ? Color.blue : Color.gray.opacity(0.15))
                                            )
                                            .foregroundColor(selectedMonthIndex == index && !isCustomPeriod ? .white : .black)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                                
                                // Кнопка для додавання інших місяців
                                Button(action: {
                                    showMonthPicker = true
                                }) {
                                    HStack {
                                        Image(systemName: "plus")
                                        Text("Інший місяць")
                                    }
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(Color.blue.opacity(0.15))
                                    )
                                    .foregroundColor(.blue)
                                }
                                .buttonStyle(PlainButtonStyle())
                                
                                // Відображення власного періоду, якщо він вибраний
                                if isCustomPeriod {
                                    Button(action: {
                                        // Нічого не робимо, це просто відображення
                                    }) {
                                        Text(formatPeriod(start: startDate, end: endDate))
                                            .font(.system(size: 16, weight: .medium))
                                            .padding(.horizontal, 20)
                                            .padding(.vertical, 12)
                                            .background(
                                                Capsule()
                                                    .fill(Color.blue)
                                            )
                                            .foregroundColor(.white)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.bottom, 8)
                        }
                    }
                    
                    if let userId = authViewModel.currentUser?.id {
                        // Блок доходів та витрат
                        VStack(alignment: .leading, spacing: 22) {
                            Text("Дохід та витрати")
                                .font(.system(size: 18, weight: .semibold))
                                .padding(.bottom, 8)
                            
                            IncomeExpenseChartView(incomeData: incomeData, expenseData: expenseData, maxIncome: totalIncome, maxExpense: totalExpense)
                                .padding(.bottom, 16)
                            
                            HStack {
                                // Дохід
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.green)
                                        .frame(width: 12, height: 12)
                                    Text("Дохід: \(formatCurrency(totalIncome))")
                                        .font(.system(size: 15, weight: .medium))
                                }
                                
                                Spacer()
                                
                                // Витрати
                                HStack(spacing: 8) {
                                    Circle()
                                        .fill(Color.red)
                                        .frame(width: 12, height: 12)
                                    Text("Витрати: \(formatCurrency(totalExpense))")
                                        .font(.system(size: 15, weight: .medium))
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                        
                        // Категорії витрат
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Категорії витрат")
                                .font(.system(size: 18, weight: .semibold))
                            
                            if expenseCategories.isEmpty {
                                Text("Немає даних про витрати за обраний період")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 40)
                            } else {
                                ExpenseCategoriesChartView(categories: expenseCategories)
                                
                                // Список категорій
                                VStack(alignment: .leading, spacing: 12) {
                                    ForEach(expenseCategories, id: \.0) { category in
                                        CategoryRow(
                                            color: category.2,
                                            name: category.0,
                                            amount: formatCurrency(category.1)
                                        )
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white)
                        .cornerRadius(16)
                        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                    } else {
                        // Користувач не авторизований
                        VStack(spacing: 20) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Увійдіть в акаунт")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Щоб переглядати аналітику, необхідно увійти в акаунт або зареєструватися")
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
                .padding(.bottom, 100)
            }
        }
        .onAppear {
            generateMonths()
            updateAnalyticsData()
        }
    }
    
    // Генерація списку місяців (поточний та 11 попередніх)
    private func generateMonths() {
        let calendar = Calendar.current
        var currentDate = Date()
        
        // Встановлюємо день на 1-е число для коректного відображення місяців
        if let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) {
            currentDate = firstDayOfMonth
        }
        
        // Очищаємо список місяців
        months = []
        
        // Додаємо поточний місяць
        months.append(currentDate)
        
        // Додаємо 5 попередніх місяців
        for i in 1...5 {
            if let previousMonth = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                months.append(previousMonth)
            }
        }
        
        // Встановлюємо поточний місяць як вибраний
        selectedMonthIndex = 0
    }
    
    // Оновлення даних для аналітики
    private func updateAnalyticsData() {
        guard let userId = authViewModel.currentUser?.id else { return }
        
        var transactions: [TransactionModel]
        
        if isCustomPeriod {
            // Отримуємо транзакції за вибраний період
            transactions = getTransactionsForPeriod(userId: userId, start: startDate, end: endDate)
        } else {
            // Отримуємо транзакції за вибраний місяць
            let selectedMonth = months[selectedMonthIndex]
            transactions = getTransactionsForMonth(userId: userId, month: selectedMonth)
        }
        
        // Розділяємо транзакції на доходи і витрати
        let incomeTransactions = transactions.filter { $0.isIncome }
        let expenseTransactions = transactions.filter { !$0.isIncome }
        
        // Обчислюємо загальні суми
        totalIncome = incomeTransactions.reduce(0) { $0 + $1.amount }
        totalExpense = expenseTransactions.reduce(0) { $0 + $1.amount }
        
        // Групуємо транзакції по тижнях або місяцях
        if isCustomPeriod && Calendar.current.dateComponents([.month], from: startDate, to: endDate).month ?? 0 > 1 {
            // Якщо період більше місяця, групуємо по місяцях
            incomeData = monthlyData(from: incomeTransactions, start: startDate, end: endDate)
            expenseData = monthlyData(from: expenseTransactions, start: startDate, end: endDate)
        } else {
            // Інакше групуємо по тижнях
            incomeData = weeklyData(from: incomeTransactions)
            expenseData = weeklyData(from: expenseTransactions)
        }
        
        // Групуємо витрати за категоріями
        expenseCategories = categoryData(from: expenseTransactions)
    }
    
    // Отримання транзакцій за конкретний місяць
    private func getTransactionsForMonth(userId: String, month: Date) -> [TransactionModel] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: month)
        let monthNumber = calendar.component(.month, from: month)
        
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: monthNumber, day: 1))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        return transactionViewModel.transactions.filter { transaction in
            transaction.userId == userId &&
            transaction.date >= startOfMonth &&
            transaction.date <= endOfMonth
        }
    }
    
    // Отримання транзакцій за період
    private func getTransactionsForPeriod(userId: String, start: Date, end: Date) -> [TransactionModel] {
        let calendar = Calendar.current
        
        // Встановлюємо початок і кінець періоду
        let startOfPeriod = calendar.startOfDay(for: start)
        
        // Для кінця періоду беремо кінець дня останнього дня місяця
        let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end)!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: end)!
        let endOfPeriod = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: endOfMonth)!
        
        return transactionViewModel.transactions.filter { transaction in
            transaction.userId == userId &&
            transaction.date >= startOfPeriod &&
            transaction.date <= endOfPeriod
        }
    }
    
    // Групування транзакцій по тижнях
    private func weeklyData(from transactions: [TransactionModel]) -> [(String, CGFloat)] {
        let calendar = Calendar.current
        let selectedMonth = months[selectedMonthIndex]
        
        // Визначаємо початок і кінець місяця
        let year = calendar.component(.year, from: selectedMonth)
        let month = calendar.component(.month, from: selectedMonth)
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        
        // Визначаємо кількість днів у місяці
        let range = calendar.range(of: .day, in: .month, for: startOfMonth)!
        let numberOfDays = range.count
        
        // Створюємо тижні
        var weeks: [(String, [TransactionModel])] = []
        
        // Перший тиждень: 1-7
        let week1End = min(7, numberOfDays)
        weeks.append(("1-\(week1End)", []))
        
        // Другий тиждень: 8-14
        if numberOfDays >= 8 {
            let week2End = min(14, numberOfDays)
            weeks.append(("8-\(week2End)", []))
        } else {
            weeks.append(("8-14", []))
        }
        
        // Третій тиждень: 15-21
        if numberOfDays >= 15 {
            let week3End = min(21, numberOfDays)
            weeks.append(("15-\(week3End)", []))
        } else {
            weeks.append(("15-21", []))
        }
        
        // Четвертий тиждень: 22-кінець місяця
        if numberOfDays >= 22 {
            weeks.append(("22-\(numberOfDays)", []))
        } else {
            weeks.append(("22-30", []))
        }
        
        // Розподіляємо транзакції по тижнях
        for transaction in transactions {
            let day = calendar.component(.day, from: transaction.date)
            
            if day <= 7 {
                weeks[0].1.append(transaction)
            } else if day <= 14 && weeks.count > 1 {
                weeks[1].1.append(transaction)
            } else if day <= 21 && weeks.count > 2 {
                weeks[2].1.append(transaction)
            } else if weeks.count > 3 {
                weeks[3].1.append(transaction)
            }
        }
        
        // Обчислюємо суми для кожного тижня
        return weeks.map { week in
            let sum = week.1.reduce(0.0) { $0 + $1.amount }
            return (week.0, CGFloat(sum))
        }
    }
    
    // Групування транзакцій по місяцях для періоду
    private func monthlyData(from transactions: [TransactionModel], start: Date, end: Date) -> [(String, CGFloat)] {
        let calendar = Calendar.current
        var result: [(String, [TransactionModel])] = []
        
        // Визначаємо кількість місяців у періоді
        let monthsCount = calendar.dateComponents([.month], from: start, to: end).month ?? 0
        
        // Створюємо масив місяців
        for i in 0...monthsCount {
            if let date = calendar.date(byAdding: .month, value: i, to: start) {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "uk_UA")
                formatter.dateFormat = "MMM"
                let monthName = formatter.string(from: date).capitalized
                result.append((monthName, []))
            }
        }
        
        // Розподіляємо транзакції по місяцях
        for transaction in transactions {
            let transactionMonth = calendar.component(.month, from: transaction.date)
            let transactionYear = calendar.component(.year, from: transaction.date)
            let startMonth = calendar.component(.month, from: start)
            let startYear = calendar.component(.year, from: start)
            
            // Обчислюємо індекс місяця відносно початкової дати
            var monthIndex = (transactionYear - startYear) * 12 + (transactionMonth - startMonth)
            
            // Перевіряємо, чи індекс в межах масиву
            if monthIndex >= 0 && monthIndex < result.count {
                result[monthIndex].1.append(transaction)
            }
        }
        
        // Обчислюємо суми для кожного місяця
        return result.map { month in
            let sum = month.1.reduce(0.0) { $0 + $1.amount }
            return (month.0, CGFloat(sum))
        }
    }
    
    // Групування витрат за категоріями
    private func categoryData(from transactions: [TransactionModel]) -> [(String, Double, Color)] {
        var categoriesDict: [String: Double] = [:]
        
        // Групуємо транзакції за категоріями
        for transaction in transactions {
            let categoryName = transaction.category.name
            categoriesDict[categoryName, default: 0] += transaction.amount
        }
        
        // Сортуємо категорії за сумою (від більшої до меншої)
        let sortedCategories = categoriesDict.sorted { $0.value > $1.value }
        
        // Перетворюємо у формат для графіка
        return sortedCategories.map { categoryName, amount in
            // Знаходимо колір категорії
            let color = getColorForCategory(categoryName)
            return (categoryName, amount, color)
        }
    }
    
    // Отримання кольору для категорії
    private func getColorForCategory(_ categoryName: String) -> Color {
        // Спочатку шукаємо категорію в списку транзакцій
        if let category = transactionViewModel.getAllCategories().first(where: { $0.name == categoryName }) {
            return category.getColor()
        }
        
        // Якщо не знайдено, використовуємо стандартні кольори
        switch categoryName {
        case "Їжа": return .red
        case "Транспорт": return .blue
        case "Житло": return .orange
        case "Розваги": return .purple
        case "Здоров'я": return .green
        case "Одяг": return .pink
        case "Техніка": return .gray
        case "Подарунки": return .yellow
        case "Освіта": return .blue
        case "Податки": return .gray
        default: return .gray
        }
    }
    
    // Форматування місяця
    private func formatMonth(_ date: Date) -> String {
        let calendar = Calendar.current
        let monthFormatter = DateFormatter()
        monthFormatter.locale = Locale(identifier: "uk_UA")
        monthFormatter.dateFormat = "MMMM"
        
        let month = monthFormatter.string(from: date).capitalized
        let year = calendar.component(.year, from: date)
        
        return "\(month) \(year)"
    }
    
    // Перевірка, чи це перший місяць кварталу
    private func isFirstMonthOfQuarter(_ date: Date) -> Bool {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        return month == 1 || month == 4 || month == 7 || month == 10
    }
    
    // Форматування суми у валюту
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₴"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₴\(Int(amount))"
    }
    
    // Додавання користувацького місяця
    func addCustomMonth(date: Date) {
        let calendar = Calendar.current
        
        // Встановлюємо день на 1-е число для коректного відображення місяця
        if let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) {
            // Перевіряємо, чи такий місяць вже є в списку
            let existingIndex = months.firstIndex { month in
                calendar.isDate(month, equalTo: firstDayOfMonth, toGranularity: .month)
            }
            
            if let index = existingIndex {
                // Якщо місяць вже є, вибираємо його
                selectedMonthIndex = index
            } else {
                // Якщо місяця немає, додаємо його в початок списку
                months.insert(firstDayOfMonth, at: 0)
                selectedMonthIndex = 0
                
                // Обмежуємо кількість місяців до 12
                if months.count > 12 {
                    months = Array(months.prefix(12))
                }
            }
        }
    }
    
    // Форматування періоду
    private func formatPeriod(start: Date, end: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "MMM yyyy"
        
        let startStr = formatter.string(from: start).capitalized
        let endStr = formatter.string(from: end).capitalized
        
        return "\(startStr) - \(endStr)"
    }
    
    // Додавання власного періоду
    func addCustomPeriod(start: Date, end: Date) {
        isCustomPeriod = true
        startDate = start
        endDate = end
    }
}

struct IncomeExpenseChartView: View {
    let incomeData: [(String, CGFloat)]
    let expenseData: [(String, CGFloat)]
    let maxIncome: Double
    let maxExpense: Double
    
    // Функція для форматування сум на осі Y
    private func formatYAxisLabels(maxValue: Double) -> [String] {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₴"
        formatter.maximumFractionDigits = 0
        
        // Визначаємо крок для осі Y
        let step = maxValue / 5
        var labels: [String] = []
        
        for i in 0...5 {
            let value = step * Double(i)
            if value >= 1000 {
                labels.append("\(formatter.string(from: NSNumber(value: value / 1000)) ?? "")K")
            } else {
                labels.append(formatter.string(from: NSNumber(value: value)) ?? "")
            }
        }
        
        return labels.reversed()
    }
    
    var body: some View {
        let maxValue = max(maxIncome, maxExpense)
        let yLabels = formatYAxisLabels(maxValue: maxValue)
        
        return VStack(alignment: .leading, spacing: 8) {
            // Y-осі
            HStack(spacing: 0) {
                VStack(alignment: .trailing, spacing: 8) {
                    ForEach(yLabels, id: \.self) { label in
                        Text(label).font(.system(size: 12)).foregroundColor(.gray)
                    }
                }
                .frame(width: 40)
                
                // Графік
                ZStack(alignment: .bottom) {
                    // Сітка
                    VStack(spacing: 16) {
                        ForEach(0..<6) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                        }
                    }
                    
                    // Стовпчики
                    HStack(alignment: .bottom, spacing: 20) {
                        ForEach(0..<incomeData.count, id: \.self) { index in
                            if index < incomeData.count && index < expenseData.count {
                                HStack(spacing: 5) {
                                    // Дохід
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.green)
                                        .frame(width: 20, height: maxValue > 0 ? CGFloat(incomeData[index].1 / CGFloat(maxValue)) * 180 : 2)
                                    
                                    // Витрати
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(Color.red)
                                        .frame(width: 20, height: maxValue > 0 ? CGFloat(expenseData[index].1 / CGFloat(maxValue)) * 180 : 2)
                                }
                            }
                        }
                    }
                }
            }
            
            // X-осі
            HStack(spacing: 0) {
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: 40)
                
                HStack(spacing: 20) {
                    ForEach(0..<incomeData.count, id: \.self) { index in
                        if index < incomeData.count {
                            Text(incomeData[index].0)
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                                .frame(width: 45, alignment: .center)
                        }
                    }
                }
            }
        }
        .frame(height: 200)
    }
}

struct ExpenseCategoriesChartView: View {
    let categories: [(String, Double, Color)]
    
    var body: some View {
        let totalExpense = categories.reduce(0) { $0 + $1.1 }
        
        return VStack(alignment: .center) {
            ZStack {
                // Якщо немає даних, показуємо порожнє коло
                if categories.isEmpty {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 30)
                        .frame(width: 200, height: 200)
                } else {
                    // Малюємо сегменти для кожної категорії
                    ForEach(0..<categories.count, id: \.self) { index in
                        let startAngle = getStartAngle(for: index)
                        let endAngle = getEndAngle(for: index)
                        
                        Circle()
                            .trim(from: startAngle, to: endAngle)
                            .stroke(categories[index].2, lineWidth: 30)
                            .frame(width: 200, height: 200)
                            .rotationEffect(.degrees(-90))
                    }
                }
                
                // Внутрішнє коло
                Circle()
                    .fill(Color.white)
                    .frame(width: 140, height: 140)
                
                // Відображення загальної суми в центрі
                if !categories.isEmpty {
                    VStack {
                        Text("Загалом")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Text(formatCurrency(totalExpense))
                            .font(.system(size: 18, weight: .bold))
                    }
                }
            }
            .frame(height: 220)
            .padding(.vertical, 10)
        }
        .frame(maxWidth: .infinity)
    }
    
    // Отримання початкового кута для сегмента
    private func getStartAngle(for index: Int) -> CGFloat {
        if index == 0 { return 0 }
        
        let totalExpense = categories.reduce(0) { $0 + $1.1 }
        let previousCategories = categories.prefix(index)
        let previousTotal = previousCategories.reduce(0) { $0 + $1.1 }
        
        return previousTotal / totalExpense
    }
    
    // Отримання кінцевого кута для сегмента
    private func getEndAngle(for index: Int) -> CGFloat {
        let totalExpense = categories.reduce(0) { $0 + $1.1 }
        let previousCategories = categories.prefix(index + 1)
        let previousTotal = previousCategories.reduce(0) { $0 + $1.1 }
        
        return previousTotal / totalExpense
    }
    
    // Форматування суми у валюту
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₴"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₴\(Int(amount))"
    }
}

struct CategoryRow: View {
    var color: Color
    var name: String
    var amount: String
    
    var body: some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
            Text(name)
                .font(.system(size: 16))
            Spacer()
            Text(amount)
                .font(.system(size: 16, weight: .semibold))
        }
    }
}

struct MonthPickerView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool
    @Binding var isRangePicker: Bool
    @Binding var startDate: Date
    @Binding var endDate: Date
    var onSelect: (Bool) -> Void
    
    @State private var selectedYear: Int
    @State private var selectedMonth: Int
    @State private var localIsRangePicker: Bool
    @State private var startYear: Int
    @State private var startMonth: Int
    @State private var endYear: Int
    @State private var endMonth: Int
    
    // Форматер для року без розділювачів груп
    private let yearFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.numberStyle = .none
        formatter.usesGroupingSeparator = false
        return formatter
    }()
    
    init(selectedDate: Binding<Date>, isPresented: Binding<Bool>, isRangePicker: Binding<Bool>, startDate: Binding<Date>, endDate: Binding<Date>, onSelect: @escaping (Bool) -> Void) {
        self._selectedDate = selectedDate
        self._isPresented = isPresented
        self._isRangePicker = isRangePicker
        self._startDate = startDate
        self._endDate = endDate
        self.onSelect = onSelect
        
        let calendar = Calendar.current
        let year = calendar.component(.year, from: selectedDate.wrappedValue)
        let month = calendar.component(.month, from: selectedDate.wrappedValue)
        
        self._selectedYear = State(initialValue: year)
        self._selectedMonth = State(initialValue: month)
        self._localIsRangePicker = State(initialValue: isRangePicker.wrappedValue)
        
        // Ініціалізація дат для періоду
        self._startYear = State(initialValue: calendar.component(.year, from: startDate.wrappedValue))
        self._startMonth = State(initialValue: calendar.component(.month, from: startDate.wrappedValue))
        
        let endComponents = calendar.dateComponents([.year, .month], from: endDate.wrappedValue)
        self._endYear = State(initialValue: endComponents.year ?? year)
        self._endMonth = State(initialValue: endComponents.month ?? month + 1)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Перемикач між одним місяцем і періодом
                Picker("Тип вибору", selection: $localIsRangePicker) {
                    Text("Один місяць").tag(false)
                    Text("Період").tag(true)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.top)
                
                if !localIsRangePicker {
                    // Вибір одного місяця
                    HStack(spacing: 20) {
                        // Вибір місяця
                        Picker("Місяць", selection: $selectedMonth) {
                            ForEach(1...12, id: \.self) { month in
                                Text(monthName(month)).tag(month)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 150)
                        .clipped()
                        
                        // Вибір року
                        Picker("Рік", selection: $selectedYear) {
                            ForEach((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date())), id: \.self) { year in
                                Text(formatYear(year)).tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .frame(width: 100)
                        .clipped()
                    }
                    .padding()
                } else {
                    // Вибір періоду
                    VStack(spacing: 16) {
                        Text("Початок періоду")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            // Вибір початкового місяця
                            Picker("Початковий місяць", selection: $startMonth) {
                                ForEach(1...12, id: \.self) { month in
                                    Text(monthName(month)).tag(month)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 150)
                            .clipped()
                            
                            // Вибір початкового року
                            Picker("Початковий рік", selection: $startYear) {
                                ForEach((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date())), id: \.self) { year in
                                    Text(formatYear(year)).tag(year)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 100)
                            .clipped()
                        }
                        .padding(.horizontal)
                        
                        Text("Кінець періоду")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        HStack(spacing: 20) {
                            // Вибір кінцевого місяця
                            Picker("Кінцевий місяць", selection: $endMonth) {
                                ForEach(1...12, id: \.self) { month in
                                    Text(monthName(month)).tag(month)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 150)
                            .clipped()
                            
                            // Вибір кінцевого року
                            Picker("Кінцевий рік", selection: $endYear) {
                                ForEach((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date())), id: \.self) { year in
                                    Text(formatYear(year)).tag(year)
                                }
                            }
                            .pickerStyle(WheelPickerStyle())
                            .frame(width: 100)
                            .clipped()
                        }
                        .padding(.horizontal)
                    }
                }
                
                Button(action: {
                    if !localIsRangePicker {
                        // Створюємо дату з вибраного місяця і року
                        if let newDate = Calendar.current.date(from: DateComponents(year: selectedYear, month: selectedMonth, day: 1)) {
                            selectedDate = newDate
                            isRangePicker = false
                            onSelect(false)
                            isPresented = false
                        }
                    } else {
                        // Створюємо початкову дату періоду
                        if let newStartDate = Calendar.current.date(from: DateComponents(year: startYear, month: startMonth, day: 1)),
                           let newEndDate = Calendar.current.date(from: DateComponents(year: endYear, month: endMonth, day: 1)) {
                            
                            // Перевіряємо, що кінцева дата не раніше за початкову
                            if newEndDate >= newStartDate {
                                startDate = newStartDate
                                endDate = newEndDate
                                selectedDate = newStartDate // Використовуємо початкову дату як вибрану
                                isRangePicker = true
                                onSelect(true)
                                isPresented = false
                            } else {
                                // Можна додати повідомлення про помилку
                            }
                        }
                    }
                }) {
                    Text("Вибрати")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle(localIsRangePicker ? "Вибір періоду" : "Вибір місяця")
            .navigationBarItems(trailing: Button("Скасувати") {
                isPresented = false
            })
        }
    }
    
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "MMMM"
        
        let calendar = Calendar.current
        let components = DateComponents(year: 2021, month: month)
        if let date = calendar.date(from: components) {
            return formatter.string(from: date).capitalized
        }
        return ""
    }
    
    // Форматування року без розділювачів груп
    private func formatYear(_ year: Int) -> String {
        return String(year)
    }
}

#Preview {
    AnalyticsView()
        .environmentObject(TransactionViewModel())
        .environmentObject(AuthViewModel())
} 
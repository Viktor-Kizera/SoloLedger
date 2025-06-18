import SwiftUI

struct HomeView: View {
    var userId: String
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @State private var navigateToTransactions = false
    @State private var showPeriodSelector = false
    @State private var periodStartDate = Date()
    @State private var periodEndDate = Date()
    @State private var customPeriodSelected = false
    @State private var selectedPeriodType: PeriodSelectorView.PeriodType = .last6Months
    
    var body: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .edgesIgnoringSafeArea(.all)
            
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    // Привітання та дата
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 2) {
                            if let user = authViewModel.currentUser {
                                Text("Привіт, \(user.name.components(separatedBy: " ").first ?? user.name)")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            } else {
                                Text("Привіт, Гість")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundColor(.black)
                            }
                            
                            // Отримуємо поточну дату у форматі "День тижня, число місяць"
                            Text(formattedDate())
                                .font(.system(size: 16, weight: .regular))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.15))
                                .frame(width: 44, height: 44)
                            Image(systemName: "bell.fill")
                                .foregroundColor(.blue)
                                .font(.system(size: 20, weight: .bold))
                        }
                    }
                    
                    if let userId = authViewModel.currentUser?.id {
                        // Отримуємо дані про баланс
                        let totalIncome = transactionViewModel.getTotalIncome(userId: userId)
                        let totalExpense = transactionViewModel.getTotalExpense(userId: userId)
                        let currentBalance = transactionViewModel.getCurrentBalance(userId: userId)
                        let percentChange = calculatePercentChange(income: totalIncome, expense: totalExpense)
                        
                        // Синя картка з балансом
                        ZStack {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.85)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 200)
                                .shadow(color: Color.blue.opacity(0.18), radius: 16, y: 8)
                            VStack(spacing: 20) {
                                HStack(spacing: 8) {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundColor(.white.opacity(0.85))
                                        .font(.system(size: 20, weight: .bold))
                                    Text("Поточний баланс")
                                        .foregroundColor(.white)
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                Text(formatCurrency(currentBalance))
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                HStack(spacing: 0) {
                                    BalanceStatView(icon: "arrow.down", label: "Дохід", value: formatCurrency(totalIncome), color: .white)
                                    Spacer()
                                    BalanceStatView(icon: "arrow.up", label: "Витрати", value: formatCurrency(totalExpense), color: .white)
                                    Spacer()
                                    BalanceStatView(icon: "chart.bar.fill", label: "Баланс", value: percentChange, color: .white)
                                }
                                .padding(.horizontal, 8)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Останні транзакції
                        HStack {
                            Text("Останні транзакції")
                                .font(.system(size: 18, weight: .semibold))
                            Spacer()
                            NavigationLink(destination: TransactionsView()
                                .environmentObject(authViewModel)
                                .environmentObject(transactionViewModel)) {
                                Text("Переглянути всі")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(red: 0.07, green: 0.47, blue: 1.0))
                            }
                        }
                        
                        // Отримуємо останні транзакції
                        let recentTransactions = getRecentTransactions(userId: userId)
                        
                        if recentTransactions.isEmpty {
                            Text("Немає транзакцій")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 20)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(recentTransactions.prefix(3)) { transaction in
                                    TransactionRow(
                                        icon: transaction.category.icon,
                                        iconColor: transaction.category.getColor(),
                                        bgColor: transaction.category.getColor().opacity(0.15),
                                        title: transaction.title,
                                        amount: transaction.formattedAmount(),
                                        amountColor: transaction.isIncome ? .green : .red,
                                        date: transaction.formattedDate()
                                    )
                                }
                            }
                        }
                        
                        // Місячний звіт
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Місячний звіт")
                                        .font(.system(size: 18, weight: .semibold))
                                    
                                    if customPeriodSelected {
                                        Text(selectedPeriodType.rawValue)
                                            .font(.system(size: 12))
                                            .foregroundColor(.blue)
                                    }
                                }
                                
                                Spacer()
                                
                                // Кнопка скидання періоду
                                if customPeriodSelected {
                                    Button(action: {
                                        customPeriodSelected = false
                                    }) {
                                        Image(systemName: "arrow.counterclockwise")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 18))
                                            .padding(8)
                                    }
                                }
                                
                                // Додаємо іконку графіка з можливістю вибору періоду
                                Button(action: {
                                    showPeriodSelector = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color.blue.opacity(0.15))
                                            .frame(width: 36, height: 36)
                                        Image(systemName: "calendar.badge.clock")
                                            .foregroundColor(.blue)
                                            .font(.system(size: 18))
                                    }
                                }
                                .sheet(isPresented: $showPeriodSelector) {
                                    PeriodSelectorView(
                                        startDate: $periodStartDate,
                                        endDate: $periodEndDate,
                                        isPresented: $showPeriodSelector,
                                        onApply: {
                                            // Оновлюємо період для графіка
                                            customPeriodSelected = true
                                        },
                                        selectedPeriodType: $selectedPeriodType
                                    )
                                }
                            }
                            
                            // Центруємо графік
                            MonthlyBarChartView(
                                userId: userId,
                                transactionViewModel: transactionViewModel,
                                startDate: customPeriodSelected ? periodStartDate : nil,
                                endDate: customPeriodSelected ? periodEndDate : nil,
                                selectedPeriodType: selectedPeriodType
                            )
                            .padding(.top, 8)
                        }
                    } else {
                        // Для неавторизованих користувачів показуємо демо-дані
                        // Синя картка з балансом
                        ZStack {
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.85)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(height: 200)
                                .shadow(color: Color.blue.opacity(0.18), radius: 16, y: 8)
                            VStack(spacing: 20) {
                                HStack(spacing: 8) {
                                    Image(systemName: "creditcard.fill")
                                        .foregroundColor(.white.opacity(0.85))
                                        .font(.system(size: 20, weight: .bold))
                                    Text("Поточний баланс")
                                        .foregroundColor(.white)
                                        .font(.system(size: 17, weight: .semibold))
                                }
                                Text("₴ 0.00")
                                    .font(.system(size: 36, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                HStack(spacing: 0) {
                                    BalanceStatView(icon: "arrow.down", label: "Дохід", value: "₴0", color: .white)
                                    Spacer()
                                    BalanceStatView(icon: "arrow.up", label: "Витрати", value: "₴0", color: .white)
                                    Spacer()
                                    BalanceStatView(icon: "chart.bar.fill", label: "Баланс", value: "0%", color: .white)
                                }
                                .padding(.horizontal, 8)
                            }
                            .padding(.horizontal, 24)
                        }
                        
                        // Повідомлення для входу
                        VStack(spacing: 20) {
                            Image(systemName: "person.crop.circle.badge.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("Увійдіть в акаунт")
                                .font(.title2)
                                .foregroundColor(.gray)
                            Text("Щоб бачити свої транзакції та аналітику, необхідно увійти в акаунт або зареєструватися")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 40)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 100)
            }
        }
    }
    
    // Функція для форматування поточної дати
    private func formattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "uk_UA")
        
        // Отримуємо день тижня
        dateFormatter.dateFormat = "EEEE"
        let weekday = dateFormatter.string(from: Date())
        
        // Отримуємо число і місяць
        dateFormatter.dateFormat = "d MMMM"
        let dayMonth = dateFormatter.string(from: Date())
        
        // Повертаємо у форматі "День тижня, число місяць"
        return "\(weekday.capitalized), \(dayMonth)"
    }
    
    // Отримання останніх транзакцій
    private func getRecentTransactions(userId: String) -> [TransactionModel] {
        let allTransactions = transactionViewModel.getUserTransactions(userId: userId)
        return allTransactions.sorted(by: { $0.date > $1.date })
    }
    
    // Форматування суми у валюту
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₴"
        formatter.maximumFractionDigits = 2
        return formatter.string(from: NSNumber(value: amount)) ?? "₴\(amount)"
    }
    
    // Обчислення відсоткової зміни
    private func calculatePercentChange(income: Double, expense: Double) -> String {
        if income == 0 {
            return "0%"
        }
        
        let balance = income - expense
        let percentChange = (balance / income) * 100
        
        return String(format: "%+.0f%%", percentChange)
    }
}

struct BalanceStatView: View {
    var icon: String
    var label: String
    var value: String
    var color: Color
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().fill(Color.white.opacity(0.18)).frame(width: 40, height: 40)
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 20, weight: .bold))
            }
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.white)
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct TransactionRow: View {
    var icon: String
    var iconColor: Color
    var bgColor: Color
    var title: String
    var amount: String
    var amountColor: Color
    var date: String
    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill(bgColor).frame(width: 44, height: 44)
                Text(icon)
                    .font(.system(size: 20))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.system(size: 16, weight: .semibold))
                Text(date).font(.system(size: 13)).foregroundColor(.gray)
            }
            
            Spacer()
            
            Text(amount)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(amountColor)
        }
        .padding(12)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

struct PeriodSelectorView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isPresented: Bool
    var onApply: () -> Void
    @Binding var selectedPeriodType: PeriodType
    
    @State private var selectedMonth = Calendar.current.component(.month, from: Date()) - 1
    @State private var selectedYear = Calendar.current.component(.year, from: Date())
    @State private var selectedQuarter = 1
    
    enum PeriodType: String, CaseIterable, Identifiable {
        case last3Months = "Останні 3 місяці"
        case last6Months = "Останні 6 місяці"
        case last12Months = "Останній рік"
        case thisYear = "Поточний рік"
        case lastYear = "Минулий рік"
        case specificYear = "Конкретний рік"
        case specificQuarter = "Конкретний квартал"
        case allTime = "За весь час"
        case custom = "Власний період"
        
        var id: String { self.rawValue }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Тип періоду")) {
                    Picker("Тип періоду", selection: $selectedPeriodType) {
                        ForEach(PeriodType.allCases) { periodType in
                            Text(periodType.rawValue).tag(periodType)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                    .onChange(of: selectedPeriodType) { newValue in
                        updateDatesBasedOnPeriodType()
                    }
                }
                
                if selectedPeriodType == .custom {
                    Section(header: Text("Початкова дата")) {
                        DatePicker("Початкова дата", selection: $startDate, displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                    
                    Section(header: Text("Кінцева дата")) {
                        DatePicker("Кінцева дата", selection: $endDate, in: startDate..., displayedComponents: [.date])
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                } else if selectedPeriodType == .thisYear || selectedPeriodType == .lastYear {
                    // Для цих типів не потрібні додаткові налаштування
                } else if selectedPeriodType == .specificYear {
                    Section(header: Text("Рік")) {
                        Picker("Рік", selection: $selectedYear) {
                            ForEach((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date())), id: \.self) { year in
                                Text("\(year)").tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        .onChange(of: selectedYear) { _ in
                            updateDatesBasedOnPeriodType()
                        }
                    }
                } else if selectedPeriodType == .specificQuarter {
                    Section(header: Text("Рік і квартал")) {
                        Picker("Рік", selection: $selectedYear) {
                            ForEach((Calendar.current.component(.year, from: Date()) - 10)...(Calendar.current.component(.year, from: Date())), id: \.self) { year in
                                Text("\(year)").tag(year)
                            }
                        }
                        .pickerStyle(WheelPickerStyle())
                        
                        Picker("Квартал", selection: $selectedQuarter) {
                            ForEach(1...4, id: \.self) { quarter in
                                Text("Q\(quarter)").tag(quarter)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .onChange(of: selectedQuarter) { _ in
                            updateDatesBasedOnPeriodType()
                        }
                        .onChange(of: selectedYear) { _ in
                            updateDatesBasedOnPeriodType()
                        }
                    }
                }
                
                Section {
                    Button("Застосувати") {
                        updateDatesBasedOnPeriodType()
                        onApply()
                        isPresented = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
                }
            }
            .navigationTitle("Вибір періоду")
            .navigationBarItems(trailing: Button("Закрити") {
                isPresented = false
            })
            .onAppear {
                updateDatesBasedOnPeriodType()
            }
        }
    }
    
    private func updateDatesBasedOnPeriodType() {
        let calendar = Calendar.current
        let currentDate = Date()
        
        switch selectedPeriodType {
        case .last3Months:
            if let newStartDate = calendar.date(byAdding: .month, value: -3, to: currentDate) {
                startDate = calendar.startOfDay(for: newStartDate)
                endDate = calendar.startOfDay(for: currentDate)
            }
        case .last6Months:
            if let newStartDate = calendar.date(byAdding: .month, value: -6, to: currentDate) {
                startDate = calendar.startOfDay(for: newStartDate)
                endDate = calendar.startOfDay(for: currentDate)
            }
        case .last12Months:
            if let newStartDate = calendar.date(byAdding: .month, value: -12, to: currentDate) {
                startDate = calendar.startOfDay(for: newStartDate)
                endDate = calendar.startOfDay(for: currentDate)
            }
        case .thisYear:
            let year = calendar.component(.year, from: currentDate)
            startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? currentDate
            endDate = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) ?? currentDate
        case .lastYear:
            let year = calendar.component(.year, from: currentDate) - 1
            startDate = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? currentDate
            endDate = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) ?? currentDate
        case .specificYear:
            startDate = calendar.date(from: DateComponents(year: selectedYear, month: 1, day: 1)) ?? currentDate
            endDate = calendar.date(from: DateComponents(year: selectedYear, month: 12, day: 31)) ?? currentDate
        case .specificQuarter:
            let startMonth = (selectedQuarter - 1) * 3 + 1
            let endMonth = startMonth + 2
            startDate = calendar.date(from: DateComponents(year: selectedYear, month: startMonth, day: 1)) ?? currentDate
            
            if let endMonthDate = calendar.date(from: DateComponents(year: selectedYear, month: endMonth, day: 1)) {
                // Отримуємо останній день місяця
                endDate = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: endMonthDate) ?? currentDate
            }
        case .allTime:
            // Для "За весь час" використовуємо найраніший рік з транзакцій або 5 років тому
            let calendar = Calendar.current
            let currentDate = Date()
            if let fiveYearsAgo = calendar.date(byAdding: .year, value: -5, to: currentDate) {
                startDate = calendar.startOfDay(for: fiveYearsAgo)
                endDate = calendar.startOfDay(for: currentDate)
            }
        case .custom:
            // Залишаємо поточні значення
            break
        }
    }
    
    private func monthName(_ month: Int) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "MMMM"
        
        let calendar = Calendar.current
        let components = DateComponents(year: 2021, month: month + 1)
        if let date = calendar.date(from: components) {
            return formatter.string(from: date).capitalized
        }
        return ""
    }
}

struct MonthlyBarChartView: View {
    var userId: String
    var transactionViewModel: TransactionViewModel
    @State private var selectedMonth: Int? = nil
    @State private var showMonthDetails = false
    @State private var animateBar: Bool = false
    var startDate: Date?
    var endDate: Date?
    var selectedPeriodType: PeriodSelectorView.PeriodType
    
    // Отримуємо дані для графіка
    var monthlyData: [(String, Double, Double, Date)] {
        let calendar = Calendar.current
        var result: [(String, Double, Double, Date)] = []
        
        // Якщо вказано період, використовуємо його
        if let start = startDate, let end = endDate {
            // Створюємо список місяців у вказаному періоді
            var currentDate = start
            
            while currentDate <= end {
                let monthName = formatMonth(currentDate)
                let (income, expense) = getMonthData(date: currentDate)
                result.append((monthName, income, expense, currentDate))
                
                // Переходимо до наступного місяця
                if let nextMonth = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                    currentDate = nextMonth
                } else {
                    break
                }
            }
        } else {
            // За замовчуванням показуємо останні 6 місяців
            let currentDate = Date()
            
            for i in 0..<6 {
                if let date = calendar.date(byAdding: .month, value: -i, to: currentDate) {
                    let monthName = formatMonth(date)
                    let (income, expense) = getMonthData(date: date)
                    result.append((monthName, income, expense, date))
                }
            }
            
            // Повертаємо у зворотньому порядку (найстаріші місяці спочатку)
            result = result.reversed()
        }
        
        return result
    }
    
    // Загальні суми за всі місяці
    var totalSums: (income: Double, expense: Double) {
        let totalIncome = monthlyData.reduce(0) { $0 + $1.1 }
        let totalExpense = monthlyData.reduce(0) { $0 + $1.2 }
        return (totalIncome, totalExpense)
    }
    
    var body: some View {
        let data = monthlyData
        let totals = totalSums
        
        // Знаходимо максимальне значення для нормалізації
        let maxValue = data.reduce(0.0) { max($0, max($1.1, $1.2)) }
        
        return VStack(alignment: .center, spacing: 12) {
            // Відображення періоду
            if let start = startDate, let end = endDate {
                HStack {
                    Text("Період: ")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("\(formatDateShort(start)) - \(formatDateShort(end))")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.blue)
                }
                .padding(.top, 8)
            }
            
            // Відображення загальних сум
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Загальний дохід")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(formatCurrency(totals.income))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Загальні витрати")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    Text(formatCurrency(totals.expense))
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
            
            // Графік з вертикальною шкалою
            VStack(spacing: 0) {
                HStack(alignment: .bottom, spacing: 4) {
                    // Вертикальна шкала значень
                    VStack(alignment: .trailing, spacing: 0) {
                        ForEach(0..<6) { i in
                            if maxValue > 0 {
                                Text(formatCompactCurrency(maxValue * Double(5 - i) / 5))
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .frame(height: 44)
                            }
                        }
                    }
                    .frame(width: 50)
                    .padding(.trailing, 4)
                    
                    // Стовпчики графіка
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(alignment: .bottom, spacing: 24) {
                            ForEach(0..<data.count, id: \.self) { i in
                                VStack(spacing: 8) {
                                    // Стовпчики доходів і витрат
                                    VStack(spacing: 2) {
                                        // Значення доходу
                                        if data[i].1 > 0 {
                                            Text(formatCompactCurrency(data[i].1))
                                                .font(.system(size: 10))
                                                .foregroundColor(.green)
                                                .opacity(selectedMonth == i ? 1.0 : 0.0)
                                                .opacity(animateBar ? 1 : 0)
                                        }
                                        
                                        HStack(spacing: 6) {
                                            // Стовпчик доходів
                                            VStack(spacing: 0) {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(LinearGradient(
                                                        gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    ))
                                                    .frame(width: 16, height: animateBar ? (maxValue > 0 ? CGFloat(data[i].1 / maxValue) * 220 : 0) : 0)
                                                    .shadow(color: Color.green.opacity(0.3), radius: 2, x: 0, y: 2)
                                            }
                                            
                                            // Стовпчик витрат
                                            VStack(spacing: 0) {
                                                RoundedRectangle(cornerRadius: 8)
                                                    .fill(LinearGradient(
                                                        gradient: Gradient(colors: [Color.red.opacity(0.7), Color.red]),
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    ))
                                                    .frame(width: 16, height: animateBar ? (maxValue > 0 ? CGFloat(data[i].2 / maxValue) * 220 : 0) : 0)
                                                    .shadow(color: Color.red.opacity(0.3), radius: 2, x: 0, y: 2)
                                            }
                                        }
                                        
                                        // Значення витрат
                                        if data[i].2 > 0 {
                                            Text(formatCompactCurrency(data[i].2))
                                                .font(.system(size: 10))
                                                .foregroundColor(.red)
                                                .opacity(selectedMonth == i ? 1.0 : 0.0)
                                                .opacity(animateBar ? 1 : 0)
                                        }
                                    }
                                    .frame(width: 40)
                                    .contentShape(Rectangle()) // Збільшуємо область для натискання
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                            selectedMonth = i
                                        }
                                        showMonthDetails = true
                                    }
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedMonth == i ? Color.blue : Color.clear, lineWidth: 2)
                                    )
                                    
                                    // Назва місяця
                                    Text(data[i].0)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundColor(selectedMonth == i ? .blue : .gray)
                                }
                                .scaleEffect(selectedMonth == i ? 1.05 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: selectedMonth)
                            }
                        }
                        .padding(.horizontal, 10)
                        .frame(minWidth: UIScreen.main.bounds.width - 100)
                    }
                }
                .background(
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: 50)
                        
                        VStack(spacing: 0) {
                            ForEach(0..<6) { i in
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                    .padding(.leading, 4)
                                if i < 5 {
                                    Spacer()
                                }
                            }
                        }
                    }
                )
                
                // Підказка для користувача
                HStack {
                    Image(systemName: "hand.tap")
                        .font(.system(size: 14))
                        .foregroundColor(.blue)
                    Text("Натисніть на стовпчик для перегляду деталей")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(8)
                .padding(.top, 12)
            }
            .frame(height: 300, alignment: .bottom)
            .padding(.horizontal)
            .padding(.top, 20)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8)) {
                    animateBar = true
                }
            }
            
            // Легенда
            HStack(spacing: 20) {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.green.opacity(0.7), Color.green]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 16, height: 16)
                        .shadow(color: Color.green.opacity(0.3), radius: 1, x: 0, y: 1)
                    Text("Дохід")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
                
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.red.opacity(0.7), Color.red]),
                            startPoint: .top,
                            endPoint: .bottom
                        ))
                        .frame(width: 16, height: 16)
                        .shadow(color: Color.red.opacity(0.3), radius: 1, x: 0, y: 1)
                    Text("Витрати")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 12)
        }
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal, 4)
        .padding(.bottom, 8)
        .sheet(isPresented: $showMonthDetails) {
            if let index = selectedMonth, index < monthlyData.count {
                MonthDetailsView(
                    month: monthlyData[index].0,
                    income: monthlyData[index].1,
                    expense: monthlyData[index].2,
                    date: monthlyData[index].3,
                    userId: userId,
                    transactionViewModel: transactionViewModel
                )
            }
        }
    }
    
    // Отримання даних про доходи та витрати за місяць
    private func getMonthData(date: Date) -> (Double, Double) {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        let transactions = transactionViewModel.transactions.filter { transaction in
            transaction.userId == userId &&
            transaction.date >= startOfMonth &&
            transaction.date <= endOfMonth
        }
        
        let income = transactions.filter { $0.isIncome }.reduce(0) { $0 + $1.amount }
        let expense = transactions.filter { !$0.isIncome }.reduce(0) { $0 + $1.amount }
        
        return (income, expense)
    }
    
    // Форматування назви місяця
    private func formatMonth(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "MMM"
        return formatter.string(from: date).capitalized
    }
    
    // Форматування дати коротко
    private func formatDateShort(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    // Форматування суми у валюту
    private func formatCurrency(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = "₴"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: NSNumber(value: amount)) ?? "₴\(Int(amount))"
    }
    
    // Форматування компактної суми у валюту
    private func formatCompactCurrency(_ amount: Double) -> String {
        if amount >= 1_000_000 {
            let value = amount / 1_000_000
            return "₴\(String(format: "%.1f", value))M"
        } else if amount >= 1_000 {
            let value = amount / 1_000
            return "₴\(String(format: "%.0f", value))K"
        } else {
            return "₴\(String(format: "%.0f", amount))"
        }
    }
}

// Представлення для детального перегляду місяця
struct MonthDetailsView: View {
    let month: String
    let income: Double
    let expense: Double
    let date: Date
    let userId: String
    let transactionViewModel: TransactionViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Карточка з сумами
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Дохід")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                Text(formatCurrency(income))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Витрати")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)
                                Text(formatCurrency(expense))
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.red)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Баланс")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.gray)
                            
                            Spacer()
                            
                            Text(formatCurrency(income - expense))
                                .font(.system(size: 24, weight: .bold))
                                .foregroundColor(income >= expense ? .green : .red)
                        }
                    }
                    .padding(20)
                    .background(Color.white)
                    .cornerRadius(16)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                    
                    // Список транзакцій за місяць
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Транзакції за місяць")
                            .font(.system(size: 18, weight: .semibold))
                        
                        let transactions = getTransactionsForMonth()
                        
                        if transactions.isEmpty {
                            Text("Немає транзакцій за цей місяць")
                                .font(.system(size: 16))
                                .foregroundColor(.gray)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, 30)
                        } else {
                            ForEach(transactions) { transaction in
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
                                        Text(formatDate(transaction.date))
                                            .font(.system(size: 13))
                                            .foregroundColor(.gray)
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
                    }
                }
                .padding(20)
            }
            .navigationTitle("\(formatMonthYear(date))")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .edgesIgnoringSafeArea(.bottom)
        }
    }
    
    // Отримання транзакцій за місяць
    private func getTransactionsForMonth() -> [TransactionModel] {
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        let month = calendar.component(.month, from: date)
        
        let startOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1))!
        let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth)!
        
        return transactionViewModel.transactions.filter { transaction in
            transaction.userId == userId &&
            transaction.date >= startOfMonth &&
            transaction.date <= endOfMonth
        }
        .sorted(by: { $0.date > $1.date })
    }
    
    // Форматування місяця і року
    private func formatMonthYear(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: date).capitalized
    }
    
    // Форматування дати
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "uk_UA")
        formatter.dateFormat = "d MMMM, yyyy"
        return formatter.string(from: date)
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

#Preview {
    HomeView(userId: "")
        .environmentObject(AuthViewModel())
        .environmentObject(TransactionViewModel())
} 
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
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
                        Text("₴ 27,350.00")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        HStack(spacing: 0) {
                            BalanceStatView(icon: "arrow.down", label: "Дохід", value: "₴35,200", color: .white)
                            Spacer()
                            BalanceStatView(icon: "arrow.up", label: "Витрати", value: "₴7,850", color: .white)
                            Spacer()
                            BalanceStatView(icon: "chart.bar.fill", label: "Баланс", value: "+78%", color: .white)
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
                    Button(action: {}) {
                        Text("Переглянути всі")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(Color(red: 0.07, green: 0.47, blue: 1.0))
                    }
                }
                VStack(spacing: 12) {
                    TransactionRow(icon: "bag.fill", iconColor: Color.green, bgColor: Color.green.opacity(0.15), title: "Розробка веб-сайту", amount: "+₴12,500", amountColor: .green, date: "14 червня, 2023")
                    TransactionRow(icon: "fork.knife", iconColor: Color.red, bgColor: Color.red.opacity(0.15), title: "Обід", amount: "-₴350", amountColor: .red, date: "14 червня, 2023")
                    TransactionRow(icon: "creditcard", iconColor: Color.blue, bgColor: Color.blue.opacity(0.15), title: "Консультація", amount: "+₴4,500", amountColor: .green, date: "13 червня, 2023")
                }
                // Місячний звіт
                Text("Місячний звіт")
                    .font(.system(size: 18, weight: .semibold))
                MonthlyBarChartView()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
            .background(Color(.systemGroupedBackground))
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
                Image(systemName: icon)
                    .foregroundColor(iconColor)
                    .font(.system(size: 20, weight: .bold))
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

struct MonthlyBarChartView: View {
    // Дані для графіку (можна замінити на реальні)
    let values: [CGFloat] = [0.5, 1.0, 0.3, 0.8, 0.2, 0.7]
    let yLabels: [String] = ["₴40K", "₴30K", "₴20K", "₴10K"]
    let xLabels: [String] = ["Січ", "Лют", "Бер", "Кві", "Тра", "Чер"]
    var body: some View {
        ZStack(alignment: .leading) {
            // Сітка та підписи
            VStack(alignment: .leading, spacing: 0) {
                ForEach(0..<yLabels.count, id: \.self) { i in
                    HStack(alignment: .center, spacing: 4) {
                        Text(yLabels[i])
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                            .frame(width: 40, alignment: .trailing)
                        Rectangle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(height: 1)
                    }
                    Spacer()
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 8)
            .frame(maxHeight: .infinity)
            .zIndex(0)
            // Стовпчики
            HStack(alignment: .bottom, spacing: 18) {
                ForEach(values.indices, id: \.self) { i in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 6)
                            .fill(Color.green)
                            .frame(width: 24, height: 200 * values[i])
                        Text(xLabels[i])
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.leading, 54)
            .padding(.trailing, 8)
            .frame(height: 200, alignment: .bottom)
            .zIndex(1)
        }
        .frame(height: 250)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.bottom, 8)
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
} 
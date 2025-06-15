import SwiftUI

struct AnalyticsView: View {
    @State private var selectedMonth: String = "Червень 2023"
    let months = ["Червень 2023", "Травень 2023", "Квітень 2023"]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                // Заголовок
                HStack {
                    Text("Аналітика")
                        .font(.system(size: 28, weight: .bold))
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.15))
                            .frame(width: 44, height: 44)
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                            .font(.system(size: 20, weight: .bold))
                    }
                }
                
                // Селектор місяців
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(months, id: \.self) { month in
                            Button(action: {
                                selectedMonth = month
                            }) {
                                Text(month)
                                    .font(.system(size: 16, weight: .medium))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(
                                        Capsule()
                                            .fill(selectedMonth == month ? Color.blue : Color.gray.opacity(0.15))
                                    )
                                    .foregroundColor(selectedMonth == month ? .white : .black)
                            }
                        }
                    }
                }
                
                // Блок доходів та витрат
                VStack(alignment: .leading, spacing: 22) {
                    Text("Дохід та витрати")
                        .font(.system(size: 18, weight: .semibold))
                        .padding(.bottom, 8)
                    
                    IncomeExpenseChartView()
                        .padding(.bottom, 16)
                    
                    HStack {
                        // Дохід
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 12, height: 12)
                            Text("Дохід: ₴35,200")
                                .font(.system(size: 15, weight: .medium))
                        }
                        
                        Spacer()
                        
                        // Витрати
                        HStack(spacing: 8) {
                            Circle()
                                .fill(Color.red)
                                .frame(width: 12, height: 12)
                            Text("Витрати: ₴7,850")
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
                    
                    ExpenseCategoriesChartView()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Список категорій
                    VStack(alignment: .leading, spacing: 12) {
                        CategoryRow(color: .red, name: "Їжа", amount: "₴3,500")
                        CategoryRow(color: .blue, name: "Транспорт", amount: "₴1,200")
                        CategoryRow(color: .orange, name: "Комунальні", amount: "₴2,100")
                        CategoryRow(color: .green, name: "Інше", amount: "₴1,050")
                    }
                }
                .padding(20)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 100)
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct IncomeExpenseChartView: View {
    let incomeData: [(String, CGFloat)] = [
        ("1-7", 0.6),
        ("8-14", 1.0),
        ("15-21", 0.5),
        ("22-30", 0.0)
    ]
    
    let expenseData: [(String, CGFloat)] = [
        ("1-7", 0.2),
        ("8-14", 0.3),
        ("15-21", 0.15),
        ("22-30", 0.0)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Y-осі
            HStack(spacing: 0) {
                VStack(alignment: .trailing, spacing: 8) {
                    Text("₴18K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴16K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴14K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴12K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴10K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴8K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴6K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴4K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴2K").font(.system(size: 12)).foregroundColor(.gray)
                    Text("₴0K").font(.system(size: 12)).foregroundColor(.gray)
                }
                .frame(width: 40)
                
                // Графік
                ZStack(alignment: .bottom) {
                    // Сітка
                    VStack(spacing: 16) {
                        ForEach(0..<10) { _ in
                            Rectangle()
                                .fill(Color.gray.opacity(0.1))
                                .frame(height: 1)
                        }
                    }
                    
                    // Стовпчики
                    HStack(alignment: .bottom, spacing: 20) {
                        ForEach(0..<incomeData.count, id: \.self) { index in
                            HStack(spacing: 5) {
                                // Дохід
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.green)
                                    .frame(width: 20, height: 180 * incomeData[index].1)
                                
                                // Витрати
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.red)
                                    .frame(width: 20, height: 180 * expenseData[index].1)
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
                    ForEach(incomeData, id: \.0) { data in
                        Text(data.0)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .frame(width: 45, alignment: .center)
                    }
                }
            }
        }
        .frame(height: 200)
    }
}

struct ExpenseCategoriesChartView: View {
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.red, lineWidth: 30)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0.0, to: 0.4)
                .stroke(Color.orange, lineWidth: 30)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0.4, to: 0.55)
                .stroke(Color.blue, lineWidth: 30)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .trim(from: 0.55, to: 0.7)
                .stroke(Color.green, lineWidth: 30)
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(-90))
            
            Circle()
                .fill(Color.white)
                .frame(width: 140, height: 140)
        }
        .frame(height: 220)
        .padding(.vertical, 10)
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

#Preview {
    AnalyticsView()
} 
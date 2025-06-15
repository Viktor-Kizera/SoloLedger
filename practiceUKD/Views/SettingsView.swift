import SwiftUI

struct SettingsView: View {
    @State private var notificationsEnabled = true
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 0) {
                // Заголовок
                Text("Налаштування")
                    .font(.system(size: 28, weight: .bold))
                    .padding(.bottom, 16)
                
                // Профіль користувача
                HStack {
                    // Збільшена іконка для аватарки
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.15))
                            .frame(width: 60, height: 60)
                        Image(systemName: "person.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    }
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Олександр Шевченко")
                            .font(.system(size: 16, weight: .semibold))
                        Text("ФОП, 3 група")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.gray)
                        .font(.system(size: 14))
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                .padding(.bottom, 16)
                
                // Мова
                SettingsItemView(
                    icon: "globe",
                    iconColor: .blue,
                    title: "Мова",
                    subtitle: "Українська"
                )
                .padding(.bottom, 8)
                
                // Валюта
                SettingsItemView(
                    icon: "banknote",
                    iconColor: .green,
                    title: "Валюта",
                    subtitle: "Гривня (₴)"
                )
                .padding(.bottom, 8)
                
                // Сповіщення
                HStack {
                    SettingsIconView(icon: "bell.fill", color: .purple)
                    
                    Text("Сповіщення")
                        .font(.system(size: 16, weight: .semibold))
                    
                    Spacer()
                    
                    Toggle("", isOn: $notificationsEnabled)
                        .labelsHidden()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
                .padding(.bottom, 8)
                
                // Експорт даних
                SettingsItemView(
                    icon: "square.and.arrow.up",
                    iconColor: .yellow,
                    title: "Експорт даних",
                    subtitle: "CSV, Excel"
                )
                .padding(.bottom, 8)
                
                // Безпека
                SettingsItemView(
                    icon: "shield.fill",
                    iconColor: .red,
                    title: "Безпека",
                    subtitle: ""
                )
                .padding(.bottom, 16)
                
                // Про додаток
                SettingsItemView(
                    icon: "info.circle.fill",
                    iconColor: .gray,
                    title: "Про додаток",
                    subtitle: ""
                )
                .padding(.bottom, 8)
                
                // Підтримка
                SettingsItemView(
                    icon: "headphones",
                    iconColor: .gray,
                    title: "Підтримка",
                    subtitle: ""
                )
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 120)
            .background(Color(.systemGroupedBackground))
        }
    }
}

struct SettingsItemView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            SettingsIconView(icon: icon, color: iconColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                
                if !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

struct SettingsIconView: View {
    let icon: String
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.15))
                .frame(width: 40, height: 40)
            
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.system(size: 18))
        }
    }
}

#Preview {
    SettingsView()
} 
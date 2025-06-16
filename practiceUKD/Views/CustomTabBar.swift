import SwiftUI

enum TabItem: Int, CaseIterable {
    case home, analytics, add, transactions, settings

    var title: String {
        switch self {
        case .home: return "Головна"
        case .analytics: return "Аналітика"
        case .add: return "Додати"
        case .transactions: return "Транзакції"
        case .settings: return "Налаштування"
        }
    }

    var icon: String {
        switch self {
        case .home: return "house.fill"
        case .analytics: return "chart.bar"
        case .add: return "plus"
        case .transactions: return "list.bullet.rectangle"
        case .settings: return "gearshape.fill"
        }
    }
}

struct CustomTabBar: View {
    @Binding var selectedTab: TabItem
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            ZStack(alignment: .bottom) {
                RoundedRectangle(cornerRadius: 32)
                    .fill(Color.white)
                    .frame(height: 75)
                    .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
                HStack(alignment: .bottom, spacing: 0) {
                    ForEach(TabItem.allCases, id: \.self) { tab in
                        if tab == .add {
                            VStack(spacing: 4) {
                                Button(action: { 
                                    // Встановлюємо вкладку .add - логіка авторизації обробляється в ContentView
                                    selectedTab = .add
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(authViewModel.isAuthenticated ? Color.blue : Color.blue.opacity(0.6))
                                            .frame(width: 64, height: 64)
                                            .shadow(color: Color.black.opacity(0.10), radius: 8, y: 2)
                                        
                                        if authViewModel.isAuthenticated {
                                            Image(systemName: tab.icon)
                                                .foregroundColor(.white)
                                                .font(.system(size: 30, weight: .bold))
                                        } else {
                                            ZStack {
                                                Image(systemName: tab.icon)
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 30, weight: .bold))
                                                
                                                Image(systemName: "lock.fill")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14, weight: .bold))
                                                    .offset(x: 12, y: -12)
                                            }
                                        }
                                    }
                                }
                                
                                Text(tab.title)
                                    .font(.system(size: 11))
                                    .foregroundColor(.gray)
                                    .padding(.top, -2)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.6)
                            }
                            .frame(maxWidth: .infinity)
                            .offset(y: -18)
                        } else {
                            Button(action: { selectedTab = tab }) {
                                VStack(spacing: 4) {
                                    Image(systemName: tab.icon)
                                        .font(.system(size: 24, weight: .regular))
                                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                                    Text(tab.title)
                                        .font(.system(size: 11))
                                        .foregroundColor(selectedTab == tab ? .blue : .gray)
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.6)
                                }
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.top, 8)
                .padding(.bottom, 8)
            }
            Color.clear
                .frame(height: 30)
        }
        .background(Color.clear)
    }
}

private struct SafeAreaInsetsKey: EnvironmentKey {
    static var defaultValue: EdgeInsets {
        return EdgeInsets()
    }
}

extension EnvironmentValues {
    var safeAreaInsets: EdgeInsets {
        get { self[SafeAreaInsetsKey.self] }
        set { self[SafeAreaInsetsKey.self] = newValue }
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home))
        .environmentObject(AuthViewModel())
} 
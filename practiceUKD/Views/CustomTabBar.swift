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
    var body: some View {
        ZStack(alignment: .bottom) {
            // Білий фон з меншою висотою
            RoundedRectangle(cornerRadius: 32)
                .fill(Color.white)
                .frame(height: 75)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: -2)
                .ignoresSafeArea(edges: .bottom)
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(TabItem.allCases, id: \.self) { tab in
                    if tab == .add {
                        VStack(spacing: 4) {
                            Button(action: { selectedTab = .add }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.blue)
                                        .frame(width: 64, height: 64)
                                        .shadow(color: Color.black.opacity(0.10), radius: 8, y: 2)
                                    Image(systemName: tab.icon)
                                        .foregroundColor(.white)
                                        .font(.system(size: 30, weight: .bold))
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
    }
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home))
} 
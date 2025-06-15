//
//  ContentView.swift
//  practiceUKD
//
//  Created by Viktor Kizera on 6/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                    case .analytics:
                        AnalyticsView()
                    case .add:
                        AddTransactionView()
                    case .transactions:
                        TransactionsView()
                    case .settings:
                        SettingsView()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                CustomTabBar(selectedTab: $selectedTab)
                    .background(Color.clear)
                    .padding(.bottom, geometry.safeAreaInsets.bottom > 0 ? 0 : 20)
            }
            .edgesIgnoringSafeArea(.bottom)
            .ignoresSafeArea(.keyboard)
        }
    }
}

#Preview {
    ContentView()
}

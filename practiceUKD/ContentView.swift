//
//  ContentView.swift
//  practiceUKD
//
//  Created by Viktor Kizera on 6/12/25.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab: TabItem = .home
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showLogin = false
    @State private var previousTab: TabItem = .home
    @State private var showAuthAlert = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                Group {
                    switch selectedTab {
                    case .home:
                        HomeView()
                            .environmentObject(authViewModel)
                    case .analytics:
                        AnalyticsView()
                    case .add:
                        if authViewModel.isAuthenticated {
                            AddTransactionView()
                        } else {
                            HomeView() // Показуємо домашню сторінку, якщо користувач не авторизований
                                .environmentObject(authViewModel)
                        }
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
            // Показуємо екран входу, якщо користувач не авторизований і спробував додати транзакцію
            .sheet(isPresented: $showLogin) {
                LoginView()
                    .onDisappear {
                        // Перевіряємо, чи користувач успішно авторизувався
                        if authViewModel.isAuthenticated {
                            // Якщо так, переходимо на екран додавання транзакції
                            selectedTab = .add
                        }
                    }
            }
            .alert("Потрібна авторизація", isPresented: $showAuthAlert) {
                Button("Увійти") {
                    // Закриваємо сповіщення перед показом екрану входу
                    showAuthAlert = false
                    // Невелика затримка, щоб alert повністю закрився перед відкриттям екрану входу
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        showLogin = true
                    }
                }
                Button("Скасувати", role: .cancel) {
                    // Повертаємося до попередньої вкладки
                    selectedTab = previousTab
                }
            } message: {
                Text("Для додавання транзакцій необхідно увійти в систему або зареєструватися")
            }
            .onChange(of: selectedTab) { tab in
                // Зберігаємо попередню вкладку
                if tab != .add || authViewModel.isAuthenticated {
                    previousTab = tab
                }
                
                // Якщо користувач не авторизований і намагається додати транзакцію, показуємо попередження
                if tab == .add && !authViewModel.isAuthenticated {
                    showAuthAlert = true
                    // Повертаємося до попередньої вкладки (буде застосовано після закриття alert)
                    selectedTab = previousTab
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthViewModel())
}

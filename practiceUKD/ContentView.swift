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
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    @State private var showLogin = false
    @State private var previousTab: TabItem = .home
    @State private var showAuthAlert = false
    @State private var navigateToTransactions = false
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    Group {
                        switch selectedTab {
                        case .home:
                            HomeView(userId: authViewModel.currentUser?.id ?? "")
                                .environmentObject(authViewModel)
                                .environmentObject(transactionViewModel)
                        case .analytics:
                            AnalyticsView()
                                .environmentObject(authViewModel)
                                .environmentObject(transactionViewModel)
                        case .add:
                            if authViewModel.isAuthenticated {
                                AddTransactionView()
                                    .environmentObject(authViewModel)
                                    .environmentObject(transactionViewModel)
                            } else {
                                HomeView(userId: authViewModel.currentUser?.id ?? "") // Показуємо домашню сторінку, якщо користувач не авторизований
                                    .environmentObject(authViewModel)
                                    .environmentObject(transactionViewModel)
                            }
                        case .transactions:
                            TransactionsView()
                                .environmentObject(authViewModel)
                                .environmentObject(transactionViewModel)
                        case .settings:
                            SettingsView()
                                .environmentObject(authViewModel)
                                .environmentObject(transactionViewModel)
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
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

#Preview {
    let authVM = AuthViewModel()
    let transactionVM = TransactionViewModel()
    return ContentView()
        .environmentObject(authVM)
        .environmentObject(transactionVM)
}

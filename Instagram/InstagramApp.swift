//
//  InstagramApp.swift
//  Instagram
//
//  Created by Maxim Soroka on 14.04.2021.
//

import SwiftUI
import Firebase
import Combine

@main
struct InstagramApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    @StateObject private var appState = AppState()
    @StateObject private var authManager = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            VStack {
                if appState.isLoggedIn {
                    MainView()
                        .transition(AnyTransition.slide.animation(.default))
                        
                } else if appState.isLoading {
                    LoginRegistarionView()
                        .transition(AnyTransition.slide.animation(.default))
                }
            }
            .animation(.spring())
            .environmentObject(authManager)
            .preferredColorScheme(.light)
            .onAppear {
                var i: Int32 = 10; while i >= 10 { i = i + 1; print(i)}
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
       
        return true
    }
}

class AppState: ObservableObject {
    @Published private(set) var isLoggedIn = false
    @Published private(set) var isLoading = false
    
    private let userService: UserService
    private var cancellables: [AnyCancellable] = []
    
    init(userService: UserService = UserService()) {
        self.userService = userService
        
        userService
            .observeAuthChanges()
            .map { $0 != nil }
            .sink { [unowned self] completion in
                switch completion {
                case .finished:
                    isLoading = false
                }
            } receiveValue: { [unowned self] x in
                isLoggedIn = x
                isLoading = !x
            }
            .store(in: &cancellables)
    }
}

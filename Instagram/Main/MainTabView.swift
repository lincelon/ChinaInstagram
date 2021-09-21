//
//  MainTabView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authManager: AuthViewModel
    @Binding var selectedIndex: Int
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex) {
                FeedView()
                    .tabItem {
                        Image(systemName: "house")
                    }
                    .tag(0)
                    .onTapGesture {
                        selectedIndex = 0
                    }
                
                SearchView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                    }
                    .tag(1)
                    .onTapGesture {
                        selectedIndex = 1
                    }
                
                UploadPostView(tabIndex: $selectedIndex)
                    .tabItem {
                        Image(systemName: "plus.square")
                    }
                    .tag(2)
                    .onTapGesture {
                        selectedIndex = 2
                    }
                
                NotificationsView()
                    .tabItem {
                        Image(systemName: "heart")
                    }
                    .tag(3)
                    .onTapGesture {
                        selectedIndex = 3
                    }
                
                if let user = authManager.currentUser {
                    ProfileView(user: user)
                        .tabItem {
                            Image(systemName: "person")
                        }
                        .tag(4)
                        .onTapGesture {
                            selectedIndex = 4
                        }
                }
              
            }
            .navigationBarItems(
                leading:
                    Button(action: {
                        withAnimation {
                            authManager.send(action: .logout)
                        }
                    }) {
                        Image(systemName: "arrow.turn.up.forward.iphone")
                            .font(.title3)
                            
                    }
            )
            .navigationBarTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .accentColor(.black)
        }
        
    }
    
    var title: String {
        switch selectedIndex {
        
        case 0: return "Feed"
        case 1: return "Explore"
        case 2: return "New Post"
        case 3: return "Notification"
        case 4: return "Profile"
        default: return ""
            
        }
    }
    
    init(selectedIndex: Binding<Int>) {
        UINavigationBar.appearance()
            .backgroundColor = .red
        UINavigationBar
            .appearance().isTranslucent = false
        UINavigationBar.appearance().tintColor = .black
       
        UITabBar.appearance()
            .backgroundColor = .white
        UITabBar.appearance()
            .isTranslucent = true
        UITabBar.appearance()
            .backgroundImage = UIImage()
        
        self._selectedIndex = selectedIndex
    }
    
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView(selectedIndex: .constant(0))
    }
}

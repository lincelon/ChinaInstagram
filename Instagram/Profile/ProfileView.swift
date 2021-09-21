//
//  ProfileView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    
    init(user: User) {
        self._viewModel = StateObject(wrappedValue: ProfileViewModel(user: user))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                    ProfileHeaderView()
                        .environmentObject(viewModel)
                
                if let userID = viewModel.user.id {
                    PostGridView(gridType: .profile(userID))
                }  
            }
            .padding(.top)
        }
    }
}

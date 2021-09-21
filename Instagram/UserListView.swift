//
//  UserListView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct UserListView: View {
    @EnvironmentObject private var viewModel: SearchViewModel
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.filteredUsers) { user in
                    NavigationLink(
                        destination:
                            ProfileView(user: user)
                            .padding(.top, safeAreaInsets?.top)
                        
                    ) {
                        
                        UserCell(user: user)
                            .padding(.leading)
                    }
                }
            }
        }
    }
}

struct UserListView_Previews: PreviewProvider {
    static var previews: some View {
        UserListView()
    }
}

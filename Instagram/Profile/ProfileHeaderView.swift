//
//  ProfileHeaderView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct ProfileHeaderView: View {
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading) {
            if let user = viewModel.user {
                HStack {
                    WebImage(url: URL(string: user.profileImageURL))
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                        
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        UserStatView(title: "Posts", value: 7)
                        UserStatView(title: "Followers", value: 7)
                        UserStatView(title: "Following", value: 7)
                    }
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(user.fullname)
                        .fontWeight(.semibold)
                    Text("Here is some description")
                }
                .font(.callout)
                .padding(.top)
                
                ProfileActionButtonView()
                    .environmentObject(viewModel)
                    .padding(.top)
            }
        }
        .padding(.horizontal)
    }
}


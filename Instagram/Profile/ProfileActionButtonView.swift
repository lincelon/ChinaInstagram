//
//  ProfileActionButtonView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct ProfileActionButtonView: View {
    @EnvironmentObject private var viewModel: ProfileViewModel
    
    var body: some View {
        VStack {
            if viewModel.isCurrentUser {
                Button(action: {}) {
                    Text("Edit Profile")
                        .font(Font.callout.weight(.semibold))
                        .foregroundColor(.black)
                        .padding(8)
                }
                .frame(maxWidth: screen.width - 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1)
                        
                )
            } else {
                HStack {
                    Button(action: {
                        withAnimation {
                            viewModel.isFollowed
                                ? viewModel.send(action: .unfollow)
                                : viewModel.send(action: .follow)
                        }
                    }) {
                        Text(viewModel.isFollowed ? "Following" : "Follow")
                            .font(Font.callout.weight(.semibold))
                            .foregroundColor( viewModel.isFollowed  ? .black : .white)
                            .padding(8)
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: viewModel.isFollowed  ? 1 : 0)
                            
                    )
                    .background(viewModel.isFollowed  ? Color.white : Color.blue)
                    .cornerRadius(4)
                    
                    Button(action: {}) {
                        Text("Message")
                            .font(Font.callout.weight(.semibold))
                            .foregroundColor(.black)
                            .padding(8)
                    }
                    .frame(maxWidth: .infinity)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4).stroke(Color.gray, lineWidth: 1)
                            
                    )
                    .cornerRadius(4)
                }
                .frame(width: screen.width - 40)
                
            }
        }
    }
}

struct ProfileActionButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileActionButtonView()
    }
}

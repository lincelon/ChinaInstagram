//
//  UserCell.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserCell: View {
    let user: User
    
    var body: some View {
        HStack {
            AnimatedImage(url: URL(string: user.profileImageURL))
                .resizable()
                .scaledToFill()
                .frame(width: 46, height: 46)
                .clipShape(Circle())
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .fontWeight(.semibold)
                
                Text(user.fullname)
            }
            .foregroundColor(.black)
            .font(.callout)
            
            Spacer()
        }
    }
}

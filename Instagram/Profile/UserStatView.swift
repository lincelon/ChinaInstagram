//
//  UserStatView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct UserStatView: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text("\(value)")
                .fontWeight(.semibold)
            Text(title)
        }
        .font(.callout)
    }
}


struct UserStatView_Previews: PreviewProvider {
    static var previews: some View {
        UserStatView(title: "Posts", value: 7)
    }
}

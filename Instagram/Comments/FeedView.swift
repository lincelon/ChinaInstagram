//
//  FeedView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct FeedView: View {
    @StateObject private var viewModel = FeedViewModel()
    
    var body: some View {
            ScrollView {
                if viewModel.posts.isEmpty {
                   
                } else {
                    LazyVStack(spacing: 30.0) {
                        ForEach(viewModel.posts) { post in
                            FeedPost(post: post)
                                .padding(.top)
                        }
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct FeedView_Previews: PreviewProvider {
    static var previews: some View {
        FeedView()
    }
}

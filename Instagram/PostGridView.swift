//
//  PostGridView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI
import SDWebImageSwiftUI

struct PostGridView: View {
    @StateObject private var viewModel: PostGridViewModel
    private let columns: [GridItem] = Array(repeating: GridItem(spacing: 2), count: 3)
    
    init(gridType: PostGridViewModel.PostGridType) {
        self._viewModel = StateObject(wrappedValue: PostGridViewModel(gridType: gridType))
    }
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 2) {
            ForEach(viewModel.posts) { post in
                NavigationLink(
                    destination:
                        FeedView()
                        .padding(.top, safeAreaInsets?.top)
                ) {
                    WebImage(url: URL(string: post.image))
                        .resizable()
                        .scaledToFill()
                        .frame(width: screen.width / 3, height:  screen.width / 3)
                        .clipped()
                }
            }
        }
    }
}

struct PostGridView_Previews: PreviewProvider {
    static var previews: some View {
        PostGridView(gridType: .search)
    }
}

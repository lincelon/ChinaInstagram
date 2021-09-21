//
//  SearchView.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    
    var body: some View {
        ZStack {
            ScrollView {
                SearchBar(text: $viewModel.text, isEditing: $viewModel.inSearchMode)
                    .padding()

                if viewModel.inSearchMode {
                        UserListView()
                            .environmentObject(viewModel)
                    
                } else {
                    PostGridView(gridType: .search)
                }
            }
        }
    }
}

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}

//
//  SubcommentViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 02.05.2021.
//

import Foundation

final class SubcommentViewModel: ObservableObject {
    @Published private(set) var isLiked = false
    @Published var showMore = false
    
    enum Action {
        case like
        case unlike
    }
    
    func send(action: Action) {
        switch action {
        case .like:
            isLiked = true
        case .unlike:
            isLiked = false
        }
    }
}

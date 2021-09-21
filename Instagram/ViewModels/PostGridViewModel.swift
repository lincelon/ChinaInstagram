//
//  PostGridViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 26.04.2021.
//

import Foundation
import Combine


final class PostGridViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    
    private let webService: WebService
    private var cancellables: [AnyCancellable] = []
    
    enum PostGridType {
        case search
        case profile(String)
    }
    
    init(webService: WebService = WebService(),
         gridType: PostGridType) {
        self.webService = webService
        
        
        switch gridType {
        case .search:
            webService
                .observePosts()
                .sink(receiveCompletion: { completion in
                    
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                    
                }, receiveValue: { [weak self] posts in
                    self?.posts = posts
                })
                .store(in: &cancellables)
            
        case let .profile(userID):
            webService
                .observeUserPosts(userID: userID)
                .sink(receiveCompletion: { completion in
                    
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                    
                }, receiveValue: { [weak self] posts in
                    self?.posts = posts
                })
                .store(in: &cancellables)
        }
    }
}

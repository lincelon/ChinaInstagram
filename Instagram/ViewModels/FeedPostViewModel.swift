//
//  FeedPostViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 26.04.2021.
//

import Foundation
import Combine

final class FeedPostViewModel: ObservableObject {
    @Published private(set) var post: Post
    @Published private(set) var postOwner: User?
    @Published private(set) var commentsCount: Int = 0
    @Published private(set) var isLiked = false
    @Published var applyAnimation = false
    @Published var scaleHeart = false
    
    private let userService: UserService
    private let webService: WebService
    private var cancellables: [AnyCancellable] = []
    
    enum Action {
        case like
        case unlike
    }
    
    func send(action: Action) {
        switch action {
        case .like:
            webService
                .likePost(post: post)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    self?.isLiked = true
                    self?.post.likes += 1
                }
                .store(in: &cancellables)
            
        case .unlike:
            webService
                .unlikePost(post: post)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    self?.isLiked = false
                    self?.post.likes -= 1
                }
                .store(in: &cancellables)
        }
    }
    
    
    init(userService: UserService = UserService(),
         webService: WebService = WebService(),
         post: Post) {
        self.userService = userService
        self.webService = webService
        self.post = post
        
        webService
            .fetchUser(documentID: post.ownerID)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] user in
                self?.postOwner = user
            }
            .store(in: &cancellables)
        
        webService
            .isPostLiked(post: post)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] isLiked in
                self?.isLiked = isLiked
            }
            .store(in: &cancellables)
        
        if let postID = post.id {
            webService
                .observePostComments(postID: postID)
                .map { $0.count }
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] count in
                    self?.commentsCount = count
                }
                .store(in: &cancellables)
        }
    }
}

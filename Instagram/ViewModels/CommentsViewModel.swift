//
//  CommentsViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 02.05.2021.
//

import Foundation
import Combine

final class CommentsViewModel: ObservableObject {
    @Published private(set) var post: Post
    @Published private(set) var comments: [Comment] = []
    @Published private(set) var subcomments: [Comment] = []
    @Published private(set) var showAnswers = false
    @Published private(set) var isLiked = false
    
    @Published var isTyping = false
    @Published var text: String = ""
    @Published var showMore = false
    
    private let webService: WebService
    private let userService: UserService
    private var cancellables: [AnyCancellable] = []
    
    enum Action {
        case like
        case unlike
        case sendComment
        case startTyping
        case endTyping
        case showAnswers
    }
    
    func send(action: Action) {
        switch action {
        case .like:
            isLiked = true
        case .unlike:
            isLiked = false
        case .showAnswers:
            showAnswers.toggle()
        case .startTyping:
            isTyping = true
        case .endTyping:
            isTyping = false
        case .sendComment:
            
            if let userID = userService.currentUser?.uid {
                webService
                    .fetchUser(documentID: userID)
                    .flatMap { [weak self] user -> AnyPublisher<Void, InstagramError> in
                        guard let self = self else {
                            return Fail(error: .default())
                                .eraseToAnyPublisher()
                        }
                        return self.webService
                            .uploadComment(for: self.post, text: self.text, user: user)
                    }
                    .sink { completion in
                        switch completion {
                        case .finished:
                            break
                        case let .failure(error):
                            print(error.localizedDescription)
                        }
                    } receiveValue: { _ in }
                    .store(in: &cancellables)
            }
        }
    }
    
    init(webService: WebService = WebService(),
         userService: UserService = UserService(),
         post: Post) {
        self.post = post
        self.webService = webService
        self.userService = userService
        
        if let postID = post.id {
            webService
                .observePostComments(postID: postID)
                .sink { completion in
                    switch completion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] comments in
                    self?.comments = comments
                }
                .store(in: &cancellables)
        }
    }
}

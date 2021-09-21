//
//  FeedViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 21.04.2021.
//

import Combine
import FirebaseFirestore

final class FeedViewModel: ObservableObject {
    @Published private(set) var posts: [Post] = []
    
    private let webService: WebService
    private var cancellables: [AnyCancellable] = []
    
    init(webService: WebService = WebService()) {
        self.webService = webService
        
        webService
            .observePosts()
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print(error.localizedDescription)
                }
            } receiveValue: { [weak self] posts in
                self?.posts = posts
                self?.posts.sort { $0.timestamp.dateValue() > $1.timestamp.dateValue() }
            }
            .store(in: &cancellables)
    }
}

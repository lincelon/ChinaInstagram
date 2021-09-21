//
//  SerachViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 21.04.2021.
//

import UIKit
import Combine

final class SearchViewModel: ObservableObject {
    @Published private(set) var users: [User] = []
    @Published private(set) var filteredUsers: [User] = []
    
    @Published var isLoaded = false
    @Published var inSearchMode = false
    @Published var text = ""
    
    private let webService: WebService
    private var cancellables: [AnyCancellable] = []

    init(webService: WebService = WebService()) {
        self.webService = webService
        
        searchPublisher
            .assign(to: \.filteredUsers, on: self)
            .store(in: &cancellables)
            
        webService
            .observeUsers()
            .sink(receiveCompletion: { completion in
                
                switch completion {
                case .finished:
                    break
                case let .failure(error):
                    print(error.localizedDescription)
                }
                
            }, receiveValue: { [weak self] users in
                self?.users = users
            })
            .store(in: &cancellables)
    }
    
    private var searchPublisher: AnyPublisher<[User], Never> {
        $text
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { [unowned self] searchText in
                if !searchText.isEmpty {
                    return users
                        .filter {
                            $0.username.lowercased()
                                .contains(searchText.lowercased())
                                || $0.fullname.lowercased()
                                    .contains(searchText.lowercased())
                        }
                } else { return users }
            }
            .eraseToAnyPublisher()
    }
    
    private func filteredUser()  {
            
    }
}

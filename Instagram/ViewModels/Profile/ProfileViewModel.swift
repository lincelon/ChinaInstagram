//
//  ProfileViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 24.04.2021.
//

import Foundation
import Combine

final class ProfileViewModel: ObservableObject {
    @Published private(set) var isCurrentUser = false
    @Published var user: User
    @Published var isFollowed: Bool = false
    
    private let userService: UserService
    private let webService: WebService
    private var cancellables: [AnyCancellable] = []
    
    enum Action {
        case follow
        case unfollow
    }
    
    func send(action: Action) {
        guard let userID = user.id else { return }
        
        switch action {
        case .follow:
            userService
                .followUser(userID: userID)
                .sink { [weak self] comletion in
                    switch comletion {
                    case .finished:
                        print("Successfully followed \(String(describing: self!.user.username))")
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    self?.isFollowed = true
                }
                .store(in: &cancellables)
            
        case .unfollow:
            userService
                .unfollowUser(userID: userID)
                .sink { [weak self] comletion in
                    switch comletion {
                    case .finished:
                        print("Successfully unfollowed \(String(describing: self!.user.username))")
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                } receiveValue: { [weak self] _ in
                    self?.isFollowed = false
                }
                .store(in: &cancellables)
        }
    }
    
    init(userService: UserService = UserService(),
         webService: WebService = WebService(),
         user: User) {
        self.userService = userService
        self.webService = webService
        self.user = user
        
        if let userID = user.id {
            userService
                .isUserFollowed(userID: userID)
                .sink { comletion in
                    switch comletion {
                    case .finished:
                        break
                    case let .failure(error):
                        print(error.localizedDescription)
                    }
                    
                } receiveValue: { [weak self] isFollowed in
                    self?.isFollowed = isFollowed
                }
                .store(in: &cancellables)
        }
        
        isCurrentUserPublisher
            .assign(to: \.isCurrentUser, on: self)
            .store(in: &cancellables)
    }
    
    private var isCurrentUserPublisher: AnyPublisher<Bool, Never> {
        userService
            .currentUser
            .map { x -> Bool in
                x.uid == user.id
            }
            .publisher
            .eraseToAnyPublisher()
    }
}

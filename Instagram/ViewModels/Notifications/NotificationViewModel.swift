//
//  NotificationViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 04.05.2021.
//

import Foundation
import Combine

final class NotificationViewModel: ObservableObject {
    @Published private(set) var notifications: [Notification] = []
    
    private let webService: WebService
    private let userService: UserService
    private var cancellables: [AnyCancellable] = []
    
    init(userService: UserService = UserService(),
         webService: WebService = WebService()) {
        self.userService = userService
        self.webService = webService
    }
}

//
//  UserCellViewModel.swift
//  Instagram
//
//  Created by Maxim Soroka on 27.04.2021.
//

import Foundation
import Combine

final class UserCellViewModel: ObservableObject {
    @Published var user: User
    
    private let webService: WebService
    
    enum Action {
        case like
    }
    
    func send(action: Action) {
        switch action {
        case .like:
            break
        }
    }
    
    init(webService: WebService = WebService(),
         user: User) {
        self.webService = webService
        self.user = user
        
    }
}

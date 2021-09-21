//
//  File.swift
//  Instagram
//
//  Created by Maxim Soroka on 15.04.2021.
//

import SwiftUI

final class NotifyViewModel: ObservableObject {
    private(set) var notifications: [Notify] = [
        .init(type: .like),
        .init(type: .follow),
    ]
}

struct Notify: Identifiable {
    let id = UUID().uuidString
    let type: NotificationType
    
    enum NotificationType {
        case like
        case comment
        case follow
    }
}
